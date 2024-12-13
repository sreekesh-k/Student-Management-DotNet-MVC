# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS base
WORKDIR /app
EXPOSE 8080

# This stage is used to build the service project
FROM base AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Student-Management-DotNet-MVC.csproj", "."]
RUN dotnet restore "./Student-Management-DotNet-MVC.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./Student-Management-DotNet-MVC.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Install dotnet-ef during the build process
RUN dotnet tool install --global dotnet-ef

# Pre-publish the project
RUN dotnet publish "./Student-Management-DotNet-MVC.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy dotnet tools from build stage
COPY --from=build /root/.dotnet/tools /root/.dotnet/tools
ENV PATH="$PATH:/root/.dotnet/tools"

# Copy published files
COPY --from=build /app/publish .

# Apply migrations explicitly pointing to the project
ENTRYPOINT ["sh", "-c", "dotnet ef database update --project /app/Student-Management-DotNet-MVC.csproj && dotnet Student-Management-DotNet-MVC.dll"]


