FROM python:3.7-buster

WORKDIR /app/

RUN pip install pipenv

COPY Pipfile Pipfile.lock .

RUN pipenv sync

COPY . . 

CMD ['pipenv', 'run', 'python', 'server.py']    
