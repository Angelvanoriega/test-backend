function validateName(name) {
  const errors = [];
  if (!name) {
    errors.push('Name can\'t be void');
  }
  if (name.length > 45) {
    errors.push('Name can\'t be greater than 45');
  }
  return errors;
}

function validateEmail(email) {
  const errors = [];
  if (!email) {
    errors.push('Email can\'t be void');
  }
  if (email.length > 45) {
    errors.push('Email can\'t be greater than 45');
  }
  const mailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  if (!mailformat.test(email)) {
    errors.push('Email must be valid');
  }
  return errors;
}

function validateBirthday(birthday) {
  const errors = [];
  if (!birthday) {
    errors.push('Birthday can\'t be void');
  }
  const dateformat = /^([0-9]{4})-([0-1][0-9])-([0-3][0-9])$/;
  if (!dateformat.test(birthday)) {
    errors.push('Birthday must be in format YYYY-MM-DD');
  }
  return errors;
}

function cleanArray(actual) {
  const newArray = [];
  for (let i = 0; i < actual.length; i += 1) {
    if (actual[i] && actual[i].length > 0) {
      newArray.push(actual[i]);
    }
  }
  return newArray;
}

function validateFields(name, email, birthday) {
  const errors = [];
  errors.push(validateName(name));
  errors.push(validateEmail(email));
  errors.push(validateBirthday(birthday));
  const allErrors = cleanArray(errors);
  if (allErrors.length > 0) {
    console.info(allErrors);
    throw new Error(allErrors);
  }
}

function validateLogin(name, email) {
  const errors = [];
  errors.push(validateName(name));
  errors.push(validateEmail(email));
  const allErrors = cleanArray(errors);
  if (allErrors.length > 0) {
    console.info(allErrors);
    throw new Error(allErrors);
  }
}
export { validateLogin, validateFields };
