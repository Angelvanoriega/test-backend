// const config = require('config')
import Koa from 'koa';
import logger from 'koa-logger';
import bodyParser from 'koa-bodyparser';
import config from './config';
import router from './router';
import db from './middleware/database';

const jwt = require('koa-jwt');
const cors = require('@koa/cors');

console.info(`ROOT_PATH: ${config.ROOT_PATH}`);
const app = new Koa();

app.use(cors());

// Custom 401 handling
app.use(async (ctx, next) => next().catch((err) => {
  if (err.status === 401) {
    ctx.status = 401;
    const errMessage = err.originalError ?
      err.originalError.message : err.message;
    ctx.body = {
      error: errMessage
    };
    ctx.set('X-Status-Reason', errMessage);
  } else {
    throw err;
  }
}));

app.use(jwt({ secret: 'secretkey' }).unless({
  path: ['/', '/login', '/register', '/sync', '/users']
}));

// sequelize & squel
app.use(db);

// rest logger
app.use(logger());
app.use(bodyParser());

// x-response-time
app.use(async (ctx, next) => {
  const start = new Date();
  await next();
  const ms = new Date() - start;
  ctx.set('X-Response-Time', `${ms}ms`);
});

app.use(router());

app.listen(process.env.PORT || 3000);
console.info(`Node ${process.version} : ${config.NODE_ENV} listening on port ${process.env.PORT || 3000}`);
