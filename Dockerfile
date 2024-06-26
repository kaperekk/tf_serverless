FROM public.ecr.aws/lambda/python:3.8

COPY function.py requirements.txt ./

RUN pip install -r requirements.txt

CMD ["function.handler"]