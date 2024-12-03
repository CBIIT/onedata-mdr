--jira 3656
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,233, 'ADD', 'Returns the sum of two values. Parameters: (value1, value2)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,234, 'SUBTRACT', 'Returns the difference of two values. Parameters: (value1, value2)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,235, 'MULTIPLY', 'Returns the product of two values. Parameters: (value1, value2)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,236, 'DIVIDE', 'Returns the quotient of two values. Parameters: (value1, value2)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,237, 'ABS', 'Returns the absolute values of a  number. Parameter: (number)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,238, 'MOD', 'Returns the remainder from division. Parameters:(number1, number2)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,239, 'POWER', 'Returns the result of a number raised to a power. Parameteres: (number1, number2)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,240, 'AVERAGE', 'Returns the average of its arguments. Parameters: (number1, number2, number3,...)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,241, 'LEFT', 'Returns the leftmost characters from a text value. Parameters: (text, number) where number is the number of the leftmost characters to extract from text.');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,242, 'RIGHT', 'Returns the rightmost characters from a text value. Parameters: (text, number) where number is the number of the rightmost characters to extract from text.');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,243, 'TRIM', 'Removes teh spaces from text. Parameter: (text)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,244, 'VALUE', 'Converts text argument to number. Parameter: (text)');
insert into obj_key (obj_typ_id, obj_key_id, obj_key_desc, obj_key_def) values (51,245, 'DATE', 'Convert to Date.');
commit;