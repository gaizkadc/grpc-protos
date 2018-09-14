# grpc-protos
Common repository to store all entities and service definitions for Nalej components using gRPC

# Building

A Makefile is provided, use:

```
$ make generate
```

To clean the generated files, use:

```
$ make clean
```

## Local tests

The dry-generate target triggers the code generation without committing or pushing code.

```
$ make dry-generate
```

# Structure

All the services and messages definitions for the Nalej components interacting through gRPC are defined in this repository. The organization of the repository matches the following example:

```
grpc-protos
├── errors
│   ├── .protolangs
│   └── errors.proto
├── organizations
│   ├── .protolangs
│   └── organizations.proto
└── clusters
    ├── .protolangs
    ├── entities.proto
    └── services.proto
```

The basic structure correspond to creating a directory per service. Naming of the files inside each service is expected to contain the name of entities or be separated in several files if the contents are no longer maintainable (e.g., entities.proto and services.proto).

On each service, a file named **.protolangs** needs to be created specifying which are the target languages for the code generation phase. For example:

```
$ cat .protolangs
go
```

Once the services are ready, the publish script will generate the appropiate code and push the changes to the related repository. Target repositories are named as `grpc-$service-$lang`

## Adding a new service

The following steps are required to add a new service. For example, assuming we want to create hello service in Nalej the following steps are required:

1. Create a new directory `mkdir hello`
2. Create a simple file `hello/hello.proto` with the message/service definition.
3. Create a `hello/.protolangs` file specifying go a s the language.
4. Create the target repository in GitHub (i.e., `grpc-hello-go`) with an initial commit
5. Commit and push the changes of `grpc-protos` and the CI/CD system will auto generate the code and publish it.
6. Alternatively, manually run the publish script.

## Checking correctness

You can check the code style rules with the following command:

```
$ make lint
```

# Autogenerating client/server stubs

The repository contains a Bash script `publishProto.sh` that automatically generate the gRPC client/server stubs and publish them to the appropiate repository for component integration. To generate those the following environment variables are expected:

* CURRENT_BRANCH: Working branch that will be used to pull/push changes to the client/server repositories.
* REPOPATH: The local path of the grpc-protos repository

For local manual pushes use:

```
$ CURRENT_BRANCH=master REPOPATH=~/go/src/github.com/nalej/grpc-protos make generate
```
