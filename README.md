# ClientServer.Azure
A template for deploying a WebSharper client-server application to Azure from source control. It uses
[paket](http://fsprojects.github.io/Paket/index.html) and `FSharp.Compiler.Tools` to build and deploy your app on Azure.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/?repository=https://github.com/intellifactory/ClientServer.Azure)

# Steps

 0. Create an Azure account at http://azure.microsoft.com if you don't have one.
 1. Click on the button above and follow the steps to set up a new Azure Web App via GitHub
 2. See your app running on the URL you configured.
 3. Every source push will trigger an update to your Azure app.
 
# How does it work?

 0. When you push to your repo, `deploy.cmd` will execute.
 1. This will curl [paket](http://fsprojects.github.io/Paket/index.html) and restore the necessary packages (`WebSharper` and `FSharp.Compiler.Tools`)
 2. It will compile your app using `msbuild`.
 3. And it will copy it to the web root/deployment folder.
 
 
