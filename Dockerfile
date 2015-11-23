#FROM gcr.io/google_appengine/base
FROM gcr.io/google_appengine/python-compat

RUN apt-get -q update && \
  apt-get install --no-install-recommends -y -q \
    build-essential git \
    libffi-dev libssl-dev libxml2-dev \
    libxslt1-dev libcurl4-openssl-dev \
    libjpeg-dev zlib1g-dev libpng12-dev \
    openssh-server \
    chrpath \
    libxft-dev \
    libfreetype6 libfreetype6-dev \
    libfontconfig1 libfontconfig1-dev \
    && \
apt-get clean && rm /var/lib/apt/lists/*_*

RUN pip install --upgrade pip virtualenv

# Install PhantomJS dependency for kindle_api
ENV PHANTOM_VERSION phantomjs-1.9.8
ENV PHANTOM_NAME $PHANTOM_VERSION-linux-x86_64
ENV PHANTOM_ARCHIVE $PHANTOM_NAME.tar.bz2

WORKDIR /phantomjs
ADD https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_ARCHIVE $PHANTOM_ARCHIVE
RUN tar xvjf $PHANTOM_ARCHIVE
ENV PATH /phantomjs/$PHANTOM_NAME/bin:$PATH

# Setup and workon a virtualenv
ENV VIRTUAL_ENV /env
ENV PATH $VIRTUAL_ENV/bin:$PATH

WORKDIR $VIRTUAL_ENV
RUN virtualenv .

# Install app and dependencies
WORKDIR /app
ENV PORT 8080

EXPOSE $PORT

ADD . .

# Install all python requirements
# sed step ensures the HTTP method used to clone repositories in lieu of
# a proper SSH authentication credential (i.e. private key)
ENV LIB_DIR /app/lib
RUN mkdir $LIB_DIR
RUN for req in `find . -name requirements.txt`; do \
        sed -i 's?git@github.com:?https://github.com/?' $req && \
            pip install -t $LIB_DIR -r $req; \
    done;

CMD []

CMD gunicorn -b 0.0.0.0:$PORT main:app
