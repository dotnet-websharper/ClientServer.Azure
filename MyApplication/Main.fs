namespace MyApplication

open WebSharper
open WebSharper.Sitelets

type Action =
    | [<CompiledName "">] Home
    | [<CompiledName "about">] About

module Server =
    [<Rpc>]
    let DoSomething input =
        let R (s: string) = System.String(List.ofSeq s |> List.rev |> Array.ofList)
        async {
            return R input
        }

[<JavaScript>]
module Client =
    open WebSharper.Html.Client

    let Main () =
        let input = Input [Attr.Value ""]
        let output = H1 []
        Div [
            input
            Button [Text "Send"]
            |>! OnClick (fun _ _ ->
                async {
                    let! data = Server.DoSomething input.Value
                    output.Text <- data
                }
                |> Async.Start
            )
            HR []
            H4 [Class "text-muted"] -- Text "The server responded:"
            Div [Class "jumbotron"] -< [output]
        ]

open WebSharper.Html.Server

module Skin =
    open System.Web

    type Page =
        {
            Title : string
            Menubar : Element list
            Body : Element list
        }

    let MainTemplate =
        Content.Template<Page>("~/Main.html")
            .With("title", fun x -> x.Title)
            .With("menubar", fun x -> x.Menubar)
            .With("body", fun x -> x.Body)

    let Menubar (ctx: Context<Action>) action =
        let ( => ) text act =
            LI [if action = act then yield Class "active"] -< [
                A [HRef (ctx.Link act)] -< [Text text]
            ]
        [
            LI ["Home" => Action.Home]
            LI ["About" => Action.About]
        ]

    let WithTemplate action title body : Content<Action> =
        Content.WithTemplate MainTemplate <| fun ctx ->
            {
                Title = title
                Menubar = Menubar ctx action
                Body = body ctx
            }

module Site =
    module Pages =
        let Home =
            Skin.WithTemplate Action.Home "Home" <| fun ctx ->
                [
                    H1 [Text "Say Hi to Azure"]
                    Div [ClientSide <@ Client.Main() @>]
                ]

        let About =
            Skin.WithTemplate Action.About "About" <| fun ctx ->
                [
                    H1 [Text "About"]
                    P [Text "This is a template WebSharper client-server application
                             that you can easily deploy to Azure from source control."]
                ]

    let Main =
        Sitelet.Infer (function
            | Action.Home -> Pages.Home
            | Action.About -> Pages.About
        )

[<Sealed>]
type Website() =
    interface IWebsite<Action> with
        member this.Sitelet = Site.Main
        member this.Actions = [Action.Home; Action.About]

[<assembly: Website(typeof<Website>)>]
do ()
