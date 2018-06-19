#--------------------------------------
# Stage: Compile Apps
#--------------------------------------
FROM python:3.6-alpine3.6 as builder

RUN apk --no-cache add build-base tar musl-utils openssl-dev
RUN pip3 install setuptools cx_Freeze==6.0b1 requests-aws4auth boto3

RUN ln -s /lib/libc.musl-x86_64.so.1 ldd
RUN ln -s /lib /lib64

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .
RUN python3 setup.py build_exe


#--------------------------------------
# Stage: Packaging Apps
#--------------------------------------
FROM alpine:3.6
RUN apk --no-cache upgrade && apk --no-cache add ca-certificates
COPY --from=builder build/exe.linux-x86_64-3.6 /curator/

#USER nobody:nobody
WORKDIR /curator

COPY config ./config

CMD ["/curator/curator", "--config", "config/config.yml", "config/action.yml"]
