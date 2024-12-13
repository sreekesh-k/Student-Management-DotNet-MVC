# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

# Ensure the app directory exists and set permissions
RUN mkdir -p /app && chmod -R 755 /app

# Switch to the application user after directory setup
USER $APP_UID

# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Student-Management-DotNet-MVC.csproj", "."]
RUN dotnet restore "./Student-Management-DotNet-MVC.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./Student-Management-DotNet-MVC.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Install dotnet-ef during the build process
RUN dotnet tool install --global dotnet-ef

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Student-Management-DotNet-MVC.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM base AS final
WORKDIR /app

# Copy dotnet tools from build stage
COPY --from=build /root/.dotnet/tools /root/.dotnet/tools
ENV PATH="$PATH:/root/.dotnet/tools"

# Ensure SQLite database file has a valid directory and set permissions
RUN mkdir -p /app && chmod -R 755 /app

COPY --from=publish /app/publish .

# Switch to the application user before running the app
USER $APP_UID

ENTRYPOINT ["dotnet", "Student-Management-DotNet-MVC.dll"]
