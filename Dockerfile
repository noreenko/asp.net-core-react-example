#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build
WORKDIR /src
COPY ["dotnet-react-example.csproj", ""]
RUN dotnet restore "./dotnet-react-example.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "dotnet-react-example.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "dotnet-react-example.csproj" -c Release -o /app/publish

# build react
FROM node AS node-builder
WORKDIR /node
COPY ./ClientApp /node
RUN npm install
RUN npm build

FROM base AS final
WORKDIR /app
RUN mkdir /app/wwwroot
COPY --from=publish /app/publish .
COPY --from=node-builder /node/build ./wwwroot
ENTRYPOINT ["dotnet", "dotnet-react-example.dll"]