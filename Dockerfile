# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Student-Management-DotNet-MVC.csproj", "."]
RUN dotnet restore "./Student-Management-DotNet-MVC.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "./Student-Management-DotNet-MVC.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Student-Management-DotNet-MVC.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Apply migrations before starting the app
ENTRYPOINT ["sh", "-c", "dotnet ef database update && dotnet Student-Management-DotNet-MVC.dll"]
