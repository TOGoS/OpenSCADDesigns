module assert_equals(expected, actual, msg=undef) {
	assert(expected == actual, str((msg == undef ? "" : str(msg, ": ")), "Expected ", expected, " but got ", actual));
}
