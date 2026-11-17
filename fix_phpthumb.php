<?php
require_once dirname(__FILE__) . '/php83_compat.php';
if (function_exists('_php83_autopatch_phpthumb')) {
	_php83_autopatch_phpthumb();
}
@unlink(__FILE__);
