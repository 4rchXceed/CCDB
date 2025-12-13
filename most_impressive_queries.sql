SELECT age *2, username, 'I can , even do this!' FROM user WHERE age = age*2-30 OR username = 'admin';

UPDATE user SET age = age + 1;