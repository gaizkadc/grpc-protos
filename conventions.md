## Nalej grpc-protos conventions
The purpose of this file is to indicate the conventions we take in nalej when creating the protos

### Structure
The basic structure correspond to creating a directory per service. 
Within each repository we will have two files, one in which we will define the entities `entities.proto` and another in which the services `service.proto` will be defined
```
grpc-protos
└── account
    ├── .protolangs
    ├── entities.proto
    └── services.proto
```

On each service, a file named `.protolangs needs to be created specifying which are the target languages for the code generation phase. In our case:
```
$ cat .protolangs
go
```

### Defining the entities
In these files we define all the messages which will be exchanged between client and server.

**some conventions:**
- the definition of the messages must include comments in order to make it more understandable
- UpdateRequest messages will have a flag per upgradeable field to indicate if this field must be updated

### Defining the services
In these files we define all the operations the server support 

**some conventions:**
- the definition of the services must include comments in order to make it more understandable
- Update and Remove services return `common.Success` object