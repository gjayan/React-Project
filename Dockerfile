FROM node:10.15.2-alpine as Builder
RUN apk add git
RUN git clone https://github.com/Sharathholla/React_devops.git
RUN cd React_devops
WORKDIR React_devops
RUN npm install
RUN npm run-script build

FROM nginx:1.22.1
EXPOSE 8080
COPY --from=Builder /React_devops/build/* /usr/share/nginx/html/
COPY --from=Builder /React_devops/build/static /usr/share/nginx/html/static
