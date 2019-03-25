const wrapper = require('./wrapper');

async function createUser(ctx, userName, userEmail, userBirthday) {
  const User = ctx.orm().user;
  const { error } = await wrapper(User.create({
    name: userName,
    email: userEmail,
    birthday: new Date(userBirthday)
  }));
  if (error) {
    throw new Error(error.original.sqlMessage);
  }
}

async function updateUser(ctx, userId, userName, userEmail, userBirthday) {
  const User = ctx.orm().user;
  const { error } = await wrapper(User.update({
    name: userName,
    email: userEmail,
    birthday: new Date(userBirthday)
  }, {
    where: { id: userId }
  }));
  if (error) {
    throw new Error(error.original.sqlMessage);
  }
}

async function destroyUser(ctx, userId) {
  const User = ctx.orm().user;
  const { data, error } = await wrapper(User.destroy({ where: { id: userId } }));
  console.info(data);
  if (error) {
    throw new Error(error.original.sqlMessage);
  }
}

async function getUserByEmailName(ctx, userName, userEmail) {
  const User = ctx.orm().user;
  const { data, error } = await wrapper(
    User.findOne(({ where: { name: userName, email: userEmail } }))
  );
  if (error) {
    throw new Error(error.original.sqlMessage);
  }
  if (data === null || typeof data === 'undefined') {
    throw new Error('User doesn\'t exists');
  } else {
    return data;
  }
}

async function getUsers(ctx) {
  const User = ctx.orm().user;
  const { data, error } = await wrapper(
    User.findAll()
  );
  if (error) {
    throw new Error(error.original.sqlMessage);
  }
  if (data === null || typeof data === 'undefined') {
    throw new Error('User doesn\'t exists');
  } else {
    return data;
  }
}

async function userExists(ctx, userId) {
  const User = ctx.orm().user;
  const { data, error } = await wrapper(User.findOne(({ where: { id: userId } })));
  if (data === null || typeof data === 'undefined') {
    throw new Error('User doesn\'t exists');
  }
  if (error) {
    throw new Error(error.original.sqlMessage);
  }
}

export { updateUser, createUser, userExists, destroyUser, getUserByEmailName, getUsers };
