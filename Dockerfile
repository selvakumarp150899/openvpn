# base image
FROM node:18.10.0 as build

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# install and cache app dependencies
COPY package.json /app/package.json
RUN npm install --force
RUN npm install -g @angular/cli@16

# add app
COPY . /app

# start app
#CMD ng serve --host 0.0.0.0

ARG BUILD_ENV

# generate build
RUN echo "Environment: ${BUILD_ENV}"
RUN npm run build-prod

############
### prod ###
############

# base image
FROM nginx:1.16.0-alpine

# copy application configuration
COPY --from=build /app/app.conf /etc/nginx/nginx.conf

# copy artifact build from the 'build environment'
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist /usr/share/nginx/html

# expose port 80
EXPOSE 80

# run nginx
CMD ["nginx", "-g", "daemon off;"]
