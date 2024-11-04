FROM python:3.11-slim

RUN mkdir /opt/pytorch-mnist
ADD mnist.py /opt/pytorch-mnist
ADD requirements.txt /opt/pytorch-mnist

WORKDIR /opt/pytorch-mnist

# Add folder for the logs.
RUN mkdir /katib
RUN pip install --prefer-binary --no-cache-dir torch==2.2.1 torchvision==0.17.1 numpy==1.26.4
RUN pip install --prefer-binary --no-cache-dir -r requirements.txt

RUN chgrp -R 0 /opt/pytorch-mnist \
  && chmod -R g+rwX /opt/pytorch-mnist \
  && chgrp -R 0 /katib \
  && chmod -R g+rwX /katib

ENTRYPOINT ["python3", "/opt/pytorch-mnist/mnist.py"]
