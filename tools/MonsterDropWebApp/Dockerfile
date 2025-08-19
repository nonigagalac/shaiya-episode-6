# Use the official .NET 8.0 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set the working directory
WORKDIR /app

# Copy the Backend project files
COPY Backend/ ./

# Restore dependencies
RUN dotnet restore "MonsterDropWebAPI.csproj"

# Build the application
RUN dotnet build "MonsterDropWebAPI.csproj" -c Release -o /app/build

# Publish the application
RUN dotnet publish "MonsterDropWebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Use the official .NET 8.0 runtime image for the final stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Set the working directory
WORKDIR /app

# Copy the published application from the build stage
COPY --from=build /app/publish .

# Expose the port the app runs on
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Define the entry point for the application
ENTRYPOINT ["dotnet", "MonsterDropWebAPI.dll"]