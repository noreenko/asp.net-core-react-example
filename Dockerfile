FROM mcr.microsoft.com/dotnet/sdk:5.0 AS dotnet-build
WORKDIR /src
COPY . /src
RUN dotnet restore "./dotnet-react-example.csproj"
RUN dotnet build "dotnet-react-example.csproj" -c Release -o /app/build

FROM dotnet-build as dotnet-publish
RUN curl -sL https://deb.nodesource.com/setup_15.x |  bash -
RUN apt-get install -y nodejs
RUN dotnet publish "dotnet-react-example.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS final
WORKDIR /app
RUN mkdir /app/wwwroot
COPY --from=dotnet-publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet-react-example.dll"]
