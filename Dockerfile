FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  wget \
  curl \
  python3 \
  python3-pip \
  python3-setuptools \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip

WORKDIR /app
ADD requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir -r /requirements.txt

ADD run.py /app

ENTRYPOINT ["python3", "run.py"]
