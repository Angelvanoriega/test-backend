import path from 'path';
import config from '../config';

const dbConfig = {
  name: config.db.alias,
  modelPath: path.join(config.ROOT_PATH, 'models'),
  db: config.db.name,
  username: config.db.username,
  password: config.db.password,
  dialect: config.db.dialect,
  host: config.db.host,
  port: config.db.port,
  pool: {
    maxConnections: 10,
    minConnections: 0,
    maxIdleTime: 30000
  },
  logging: false
};

const orm = require('koa-orm')(dbConfig);

export default orm.middleware;
