# aswrap

AWS assume role credential wrapper.

## Description

aswrap is useful for some commands which couldn't resolve an assume role credentials in ~/.aws/credentials.

For example,

- Implemented with [aws-sdk-go](https://github.com/aws/aws-sdk-go)
- [Terraform](https://www.terraform.io/)
- [Packer](https://www.packer.io/)
- etc.

## Install

Place a `aswrap` command to your PATH and set an executable flag.

```console
$ curl -Lso path/to/aswrap https://github.com/fujiwara/aswrap/releases/download/v0.0.1/aswrap && chmod +x path/to/aswrap
```

## Usage

```ini
# ~/.aws/credentials

[my-profile]
aws_access_key_id=XXX
aws_secret_access_key=YYY

[foo]
region=ap-northeast-1
source_profile=my-profile
role_arn=arn:aws:iam::999999999999:role/MyRole
```

### As command wrapper

```console
$ AWS_PROFILE=foo aswrap some_command [arg1 arg2...]
```

`aswrap` works as below.

1. Find `AWS_PROFILE` section in ~/.aws/credentials and ~/.aws/config .
2. Call `aws sts assume-role` to a get temporary credentials.
3. Set the credentilas to environment variables.
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN`
   - `AWS_REGION` if available in the section.
4. Execute `some_command` with args.

### As env exporter

When aswrap is executed with no arguments, aswrap outputs shell script to export AWS credentials environment variables.

```console
$ export AWS_PROFILE=foo
$ aswrap
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=eW8JjiLZk+mzNmEQJyORdzk....
export AWS_SESSION_TOKEN=2b0gN9qucmINvL8D4sgpLbzvJ31Es5/VBy9gYFpxKFWBrODYMBqcq5WksJGp9RW.....
export AWS_REGION=ap-northeast-1
```

You can set the credentials in current shell by `eval`.

```console
$ eval "$(aswrap)"
```

Temporary credentials has expiration time (about 1 hour).

## Requirements

- Perl (>= 5.14.0)
  - required JSON::PP
- [aws-cli](https://github.com/aws/aws-cli)

## LICENSE

MIT License

## Author

Copyright (c) 2017 FUJIWARA Shunichiro

