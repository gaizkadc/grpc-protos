# grpc-protos

Common repository to store all entities and service definitions for Nalej components using gRPC.

## Getting Started

Any information required by the final user to use this repo.

### Building

A Makefile is provided, use:

```
$ make generate
```

To clean the generated files, use:

```
$ make clean
```

#### Local tests

The dry-generate target triggers the code generation without committing or pushing code.

```
$ make dry-generate
```

### Structure

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

#### Adding a new service

The following steps are required to add a new service. For example, assuming we want to create hello service in Nalej the following steps are required:

1. Create a new directory `mkdir hello`
2. Create a simple file `hello/hello.proto` with the message/service definition.
3. Create a `hello/.protolangs` file specifying go a s the language.
4. Create the target repository in GitHub (i.e., `grpc-hello-go`) with an initial commit
5. Commit and push the changes of `grpc-protos` and the CI/CD system will auto generate the code and publish it.
6. Alternatively, manually run the publish script.

#### Checking correctness

This functionality requires to install protoc-gen-lint. You can install it using the following command:

```
$ go get github.com/ckaznocha/protoc-gen-lint
```

You can check the code style rules with the following command:

```
$ make lint
```

## Autogenerating client/server stubs - Deprecated

The repository contains a Bash script `publishProto.sh` that automatically generate the gRPC client/server stubs and publish them to the appropiate repository for component integration. To generate those the following environment variables are expected:

* CURRENT_BRANCH: Working branch that will be used to pull/push changes to the client/server repositories.
* REPOPATH: The local path of the grpc-protos repository

For local manual pushes use:

```
$ CURRENT_BRANCH=master REPOPATH=~/go/src/github.com/nalej/grpc-protos make generate
```

## Compiling a single service - Deprecated

To generate a single service use:

```
$ make generate service=serviceName
```

You can also use any other make targets

## Known Issues

* The `publishProto.sh` is deprecated and the generation of new versions of a proto repo is done by the CI system
to determine accurately whether changes have been made to a directory and a new proto version needs to be generated.
* Documentation related to some services/entities is to be improved as some of it is missing.

## Contributing

Please read [contributing.md](contributing.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/nalej/grpc-protos/tags). 

## Authors

See also the list of [contributors](https://github.com/nalej/grpc-protos/contributors) who participated in this project.

## License
This project is licensed under the Apache 2.0 License - see the [LICENSE-2.0.txt](LICENSE-2.0.txt) file for details.
