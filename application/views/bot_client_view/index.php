<?php 
	$this->load->view('header');
	$this->load->view('header_end');
	$this->load->view('modules/mod_header'); 
?>
<?php	
	
	switch ($event) 
	{
		case 'view':
			$this->load->view('bot_client_view/bot_client_listview');
			break;			
		case 'add':
			$this->load->view('bot_client_view/bot_client');
			break;
		case 'edit': 
			$this->load->view('bot_client_view/bot_client');
			break;
		case 'update_add': 
			$this->load->view('bot_client_view/bot_client');
			break;		
		case 'update_edit': 
			$this->load->view('bot_client_view/bot_client');
			break;
			
		case 'balance_report': 
			$this->load->view('bot_client_view/balance_report_listview');
			break;
		
		case 'bot_license_history': 
			$this->load->view('bot_client_view/bot_license_history_listview');
			break;

		// BỔ SUNG CASE HIỂN THỊ THÙNG RÁC:
		case 'trash': 
			$this->load->view('bot_client_view/trash_list');
			break;
			
		default:
			echo $event . ' invalid event view site. please cotact with admin site for more informations';
	}
?>
<?php
	$this->load->view('modules/mod_footer');
	$this->load->view('footer');
?>