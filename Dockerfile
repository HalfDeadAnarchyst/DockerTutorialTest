FROM python:3.5

# Create app directory
WORKDIR /app

# Install app dependencies
# COPY src/requirements.txt ./

# RUN pip install -r requirements.txt

# Bundle app source
COPY src /app

EXPOSE 80
CMD [ "python", "PyWebListener.py" ]