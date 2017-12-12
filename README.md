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
$ curl -so path/to/aswrap https://raw.githubusercontent.com/fujiwara/aswrap/master/aswrap && chmod +x path/to/aswrap
```

## Usage

```ini
[my-profile]
aws_access_key_id=XXX
aws_secret_access_key=YYY

[foo]
region=ap-northeast-1
source_profile=my-profile
role_arn=arn:aws:iam::999999999999:role/MyRole
```

```console
$ AWS_PROFILE=foo aswrap some_command [arg1 arg2...]
```

`aswrap` works as below.

1. Find `AWS_PROFILE` section in $HOME/.aws/credentials .
2. Call `aws sts assume-role` to a get temporary credentials.
3. Set the credentilas to environment variables.
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN`
   - `AWS_REGION` if available in the section.
4. Execute `some_command` with args.

## Requirements

- Perl (>= 5.14.0)
  - required JSON::PP
- [aws-cli](https://github.com/aws/aws-cli)

## LICENSE

MIT License

## Author

Copyright (c) 2017 FUJIWARA Shunichiro

