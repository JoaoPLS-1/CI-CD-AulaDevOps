# Respostas — Atividade de DevOps com Podman

## Etapa 3 — O conflito de nomes

**O que aconteceu ao tentar criar outro container chamado `site-aluno`?**

O Podman impediu a criação e apresentou a mensagem:

```text
the container name "site-aluno" is already in use
```

**Por que o Podman impediu a criação?**

Cada container precisa ter um nome único no mesmo ambiente do Podman. Um container parado também mantém seu nome reservado. Usar outra imagem não libera esse nome.

Nesta execução, o container anterior existente se chamava `devopsAula`. Para reproduzir o conflito solicitado, foi criado um container parado chamado `site-aluno` com a imagem anterior, `localhost/devops:latest`. A tentativa abaixo foi então recusada:

```powershell
podman run -d --name site-aluno meu-site-v2
```

## Etapa 4 — Resolução de problemas

**Como remover permanentemente o container antigo?**

Como o container antigo estava parado, foi utilizado:

```powershell
podman rm site-aluno
```

Se estivesse em execução, seria necessário pará-lo antes com `podman stop site-aluno`, ou removê-lo com `podman rm -f site-aluno`.

**Como iniciar a nova versão em outra porta?**

```powershell
podman run -d --name site-aluno -p 9999:80 meu-site-v2
```

O mapeamento `9999:80` encaminha a porta 9999 do computador para a porta 80 do container, onde o Nginx atende. O novo site fica disponível em <http://localhost:9999>. O container `devopsAula` continua usando a porta 8888.

## Etapa 5 — Validação final

**O site mostra a cor nova e o título da versão 2.0?**

Sim. O endereço <http://localhost:9999> foi aberto no navegador. A validação dos arquivos servidos confirmou HTTP 200 para o HTML e o CSS, com:

- Título principal: `Projeto DevOps - Versão 2.0 (Container)`.
- Cor de fundo: azul-marinho (`#142d4e`).
- Container: `site-aluno`, usando a imagem `localhost/meu-site-v2:latest`.

O `Containerfile` inclui tanto o HTML quanto o CSS para disponibilizar o novo visual:

```dockerfile
FROM nginx:alpine
COPY index.html styles.css /usr/share/nginx/html/
EXPOSE 80
```

A imagem foi construída com:

```powershell
podman build -t meu-site-v2 -f Containerfile .
```

**Se o site antigo ainda aparecer, onde pode ter ocorrido o erro?**

- Acesso à porta antiga: `localhost:8888` continua servindo a versão anterior; a nova usa `localhost:9999`.
- Imagem construída antes de salvar as alterações: é necessário salvar os arquivos e reconstruir a imagem.
- Container iniciado com a imagem anterior: é necessário recriar o container usando `meu-site-v2`. Reconstruir a imagem não atualiza automaticamente um container já existente.
- Arquivos ausentes na imagem: o `Containerfile` precisa copiar também o `styles.css` para que a nova cor seja aplicada.
- Cache do navegador: usar `Ctrl + F5` para recarregar a página.
