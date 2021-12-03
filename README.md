# CaseSwap

## Usage Instructions 

### English
A service that retrieves all issues from a given repository on github and returns a JSON asynchronously (1 day apart) via webhook with issues and contributors that existed in the project at the time of the call.

Entries:
  - User Name
  - Repository Name

The `create_repository_webhook_swap!` Function implements the specified business rules, posting after 24 Hours on the endpoint caught at webhook.site ( https://webhook.site/#!/8b28f032-eef5-46f7-aa87-a3b9237d9768/029ae227 -ff31-46e4-bf27-6d53af6a987d/1 ).

Usage: `CaseSwap.create_repository_webhook_swap!(user_name, repository_name)`

This function is a curry on a more generic function, the `create_repository_webhook!` which in addition to the username and repository name also receives the `target_url` for the webhook and `time` to define how long (in milliseconds) to send the webhook (Useful for testing functionality in short times)

### Portuguese
Um serviço que recupere todas as issues de um determinado repositório no github e retorne um JSON assincronamente (1 dia de diferença) via webhook com as issues e contribuidores que existiam no projeto no momento da chamada.

Entrada:
- Nome do usuário
- Nome do repositório

A Função 'create_repository_webhook_swap!' implementam as regras de negócio especificadas, fazendo o post depois de 24 Horas no endpoint pego no webhook.site ( https://webhook.site/#!/8b28f032-eef5-46f7-aa87-a3b9237d9768/029ae227-ff31-46e4-bf27-6d53af6a987d/1 ).

Uso: 'CaseSwap.create_repository_webhook_swap!(nome_do_usuario, nome_do_repositorio)'

Essa função é um curry em uma função mais genérica, a 'create_repository_webhook!' que além do nome do usuário e nome do repositório também recebe a 'target_url' para o webhook e 'time' para definir em quanto tempo (em milissegundos) mandar o webhook (Útil para testar a funcionalidade em tempos curtos)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `case_swap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:case_swap, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/case_swap](https://hexdocs.pm/case_swap).

