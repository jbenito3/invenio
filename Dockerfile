# -*- coding: utf-8 -*-
#
# This file is part of Invenio.
# Copyright (C) 2015, 2016, 2017 CERN.
#
# Invenio is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# Invenio is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Invenio; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307, USA.
#
# In applying this license, CERN does not
# waive the privileges and immunities granted to it by virtue of its status
# as an Intergovernmental Organization or submit itself to any jurisdiction.

# Use Python-2.7:
FROM python:2.7-slim

# Configure Invenio instance:
ENV INVENIO_WEB_INSTANCE=invenio
ENV INVENIO_INSTANCE_PATH=/usr/local/var/instance

# Add Invenio sources to `code` and work there:
WORKDIR /code
ADD . /code

RUN apt-get -y update \
    && apt-get -y install \
     libffi-dev \
     libfreetype6-dev \
     libjpeg-dev \
     libmsgpack-dev \
     libssl-dev \
     libtiff-dev \
     libxml2-dev \
     libxslt-dev \
     nodejs \
     python-dev \
     python-pip
RUN apt-get -qy install --fix-missing --no-install-recommends apt-utils curl \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get -qy install --fix-missing --no-install-recommends nodejs

# Install Invenio

RUN pip install invenio-app-ils[postgresql,elasticsearch2] \
    && mkdir -p ${INVENIO_INSTANCE_PATH} \
    && ${INVENIO_WEB_INSTANCE} npm \
    && npm update && npm install --silent -g node-sass@3.8.0 clean-css@3.4.19 uglify-js@2.7.3 requirejs@2.2.0 \
    && cd ${INVENIO_INSTANCE_PATH}/static \
    && CI=true npm install \
    && ${INVENIO_WEB_INSTANCE} collect -v \
    && ${INVENIO_WEB_INSTANCE} assets build \
    && chmod -R 777 ${INVENIO_INSTANCE_PATH}


# Start the Invenio application:
CMD ["/bin/bash", "-c", "invenio run -h 0.0.0.0"]
