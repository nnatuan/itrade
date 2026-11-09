<?php
class ajax_actions extends CI_Controller
{
    function __construct()
	{ 
		parent::__construct();
        session_start();
        $this->load->database();
        $this->load->helper('ap_db');
        $this->load->helper('ap_object');
        $this->load->helper('ap_function');
        $this->load->helper('ap_view');
        //$this->load->helper('ap_module');
        //$this->load->helper('ap_cart');
        //$this->load->helper('ap_mail');
		//$this->tokaban_system_check = '1'; 
		$this->config->check_system_login = '1';
    }
	function phat_sinh_ma_giam_gia() {
		$sl        = '';
		$cper        = '';
		$ctype        = '';
		$call        = '';
		if (isset($_POST['sl']))
            $sl = $_POST['sl'];
		if (isset($_POST['cper']))
            $cper = $_POST['cper'];
		if (isset($_POST['ctype']))
            $ctype = $_POST['ctype'];
		if (isset($_POST['call']))
            $call = $_POST['call'];
		for($i=0;$i<$sl;$i++) {
			$s = substr(str_shuffle(str_repeat("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", 6)), 0, 6);
			$data = array(
				'cname' => $s,
				'ccode' => $s,
				'cper' => $cper,
				'ctype' => $ctype,
				'call' => $call,
				'cactive' => "0",
				'nstatus' => 1
			);
			$this->db->insert('tcode_sale', $data);
		}
		exit("done");
	}
	
	//xoa cache
	function clear_cache() {
        $path_to_file = './../ap_application/cache/';

        $dir = $path_to_file;
           foreach(glob($dir.'*') as $v){
                unlink($v);
            }
    }
	
	function insert_order_vtp()
    {
		if(isset($_SESSION['token'])) {
			$nid_user = Fget_userdata('session_nid_user');
			$ccode_order = '';
			$ORDER_NUMBER = '';
			$to_name = '';
			$to_phone = '';
			$to_address = '';
			$RECEIVER_WARD = '';
			$RECEIVER_DISTRICT = '';
			$RECEIVER_PROVINCE = '';
			$MONEY_COLLECTION = '';
			$MONEY_VAT = '';
			$weight = '';
			$length = '';
			$width = '';
			$height = '';
			$ORDER_PAYMENT = '';
			$ORDER_SERVICE = '';
			$ORDER_NOTE = '';
			$payment_type_id = '';
			
			$nid_order_active = '';
			$product_list = '';
			$ntotal = '';
			$cgiam_gia = '';
			$full_address = '';
			
			if (isset($_POST['ccode_order']))
				$ccode_order = $_POST['ccode_order'];
			if (isset($_POST['ORDER_NUMBER']))
				$ORDER_NUMBER = $_POST['ORDER_NUMBER'];
			if (isset($_POST['to_name']))
				$to_name = $_POST['to_name'];
			if (isset($_POST['to_phone']))
				$to_phone = $_POST['to_phone'];
			if (isset($_POST['to_address']))
				$to_address = $_POST['to_address'];
			if (isset($_POST['RECEIVER_WARD']))
				$RECEIVER_WARD = $_POST['RECEIVER_WARD'];
			if (isset($_POST['RECEIVER_DISTRICT']))
				$RECEIVER_DISTRICT = $_POST['RECEIVER_DISTRICT'];
			if (isset($_POST['RECEIVER_PROVINCE']))
				$RECEIVER_PROVINCE = $_POST['RECEIVER_PROVINCE'];
			if (isset($_POST['MONEY_COLLECTION']))
				$MONEY_COLLECTION = $_POST['MONEY_COLLECTION'];
			if (isset($_POST['weight']))
				$weight = $_POST['weight'];
			if (isset($_POST['length']))
				$length = $_POST['length'];
			if (isset($_POST['width']))
				$width = $_POST['width'];
			if (isset($_POST['height']))
				$height = $_POST['height'];
			if (isset($_POST['MONEY_VAT']))
				$MONEY_VAT = $_POST['MONEY_VAT'];
			if (isset($_POST['ORDER_PAYMENT']))
				$ORDER_PAYMENT = $_POST['ORDER_PAYMENT'];
			if (isset($_POST['ORDER_SERVICE']))
				$ORDER_SERVICE = $_POST['ORDER_SERVICE'];
			if (isset($_POST['ORDER_NOTE']))
				$ORDER_NOTE = $_POST['ORDER_NOTE'];
			if (isset($_POST['payment_type_id']))
				$payment_type_id = $_POST['payment_type_id'];
			
			if (isset($_POST['nid_order_active']))
				$nid_order_active = $_POST['nid_order_active'];
			if (isset($_POST['product_list']))
				$product_list = $_POST['product_list'];
			if (isset($_POST['ntotal']))
				$ntotal = $_POST['ntotal'];
			if (isset($_POST['cgiam_gia']))
				$cgiam_gia = $_POST['cgiam_gia'];
			if (isset($_POST['full_address']))
				$full_address = $_POST['full_address'];
			
			//tạo đơn vtp
			$setting = get_setting_by_user(Fget_userdata('session_nid_user'));
			
			$LIST_ITEM = [];
			$list = json_decode($product_list,true);
			foreach($list as $item) {
				$arr = array(
					"PRODUCT_NAME" => $item['name'],
					"PRODUCT_PRICE" => (float)$item['price'],
					//"PRODUCT_WEIGHT" => 2500,
					"PRODUCT_QUANTITY" => (int)$item['quantity']
				);
				$LIST_ITEM[] = $arr;
			}
			//exit(json_encode($LIST_ITEM));
			
			$par = array(
				//"ORDER_NUMBER" => $ORDER_NUMBER,
				"ORDER_REFERENCE" => $ccode_order,
				"SENDER_FULLNAME" => $setting['ccompany'],
				"SENDER_ADDRESS" => $setting['caddress'],
				"SENDER_PHONE" => $setting['cphone'],
				"SENDER_WARD" => $setting['nid_ward'],
				"SENDER_DISTRICT" => $setting['nid_district'],
				"SENDER_PROVINCE" => $setting['nid_province'],
				
				"RECEIVER_FULLNAME" => $to_name,
				"RECEIVER_ADDRESS" => $to_address,
				"RECEIVER_PHONE" => $to_phone,
				"RECEIVER_WARD" => $RECEIVER_WARD,
				"RECEIVER_DISTRICT" => $RECEIVER_DISTRICT,
				"RECEIVER_PROVINCE" => $RECEIVER_PROVINCE,
				
				"MONEY_COLLECTION" => (float)$MONEY_COLLECTION,
				"PRODUCT_WEIGHT" => (int)$weight,
				"PRODUCT_LENGTH" => (int)$length,
				"PRODUCT_WIDTH" => (int)$width,
				"PRODUCT_HEIGHT" => (int)$height,
				"PRODUCT_TYPE" => "HH",
				"ORDER_PAYMENT" => $ORDER_PAYMENT,
				"ORDER_SERVICE" => $ORDER_SERVICE,
	  
				"MONEY_VAT" => (float)$MONEY_VAT,
				"ORDER_NOTE" => $ORDER_NOTE,
				//"LIST_ITEM" => json_decode($product_list,true),
				"LIST_ITEM" => $LIST_ITEM
			);
			//exit(json_encode($par));
			
			$url = 'https://partner.viettelpost.vn/v2/order/createOrder';
			$curl = curl_init();

			curl_setopt_array($curl, array(
			  CURLOPT_URL => $url,
			  CURLOPT_RETURNTRANSFER => true,
			  CURLOPT_ENCODING => '',
			  CURLOPT_MAXREDIRS => 10,
			  CURLOPT_TIMEOUT => 0,
			  CURLOPT_FOLLOWLOCATION => true,
			  CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
			  CURLOPT_CUSTOMREQUEST => 'POST',
			  //CURLOPT_POSTFIELDS => $par,
			  CURLOPT_POSTFIELDS => json_encode($par),		
			  CURLOPT_HTTPHEADER => array(
				"Content-Type: application/json",
				//"token: ".$setting['ctoken']
				"token: ".$_SESSION['token']
			  ),
			));

			$response = curl_exec($curl);
			$err = curl_error($curl);
			curl_close($curl);
			
			if ($err) {
				exit("cURL Error #:" . $err);
			 // echo "cURL Error #:" . $err;
			} else {
				$res = json_decode($response,true);
				//tạo đơn local
				if($res['status']==200) {
					if($ccode_order!='') {
						$code_vtp = $res['data']['ORDER_NUMBER'];				
						$this->db->set('ccode_vtp', $code_vtp);
						$this->db->where('ccode', $ccode_order);
						$this->db->update('torder');
					} else {
						$cus = get_customer_by_phone($to_phone);
						if(!isset($cus['nid'])) {
							$data_customer           = array(
								"cname" => $to_name,
								"cphone" => $to_phone,
								//"caddress" => $to_address . ', ' . $RECEIVER_WARD . ', ' . $RECEIVER_DISTRICT . ', ' . $RECEIVER_PROVINCE,
								//"caddress" => $to_address,
								"caddress" => $full_address,
								//"niduser01"  => $nid_user,
								"ddate01" => date("Y-m-d"),
							);		
							$this->db->insert("tcustomer", $data_customer);
							$id_customer = dbget_identity();
						} else 
							$id_customer = $cus['nid'];
						
						$code_vtp = $res['data']['ORDER_NUMBER'];				
						$data           = array(
											"ccode_vtp" => $code_vtp,
											"nid_customer" => $id_customer,
											"cfullname" => $to_name,
											"nphone" => $to_phone,
											//"caddress" => $to_address . ', ' . $RECEIVER_WARD . ', ' . $RECEIVER_DISTRICT . ', ' . $RECEIVER_PROVINCE,
											//"caddress" => $to_address,
											"caddress" => $full_address,
											"cnote" => $ORDER_NOTE,
											"ntotal" => $ntotal,
											//"cship" => Fstr_replace(',','',$cship),
											//"cgiam_gia" => $cgiam_gia,
											"cin_hoa_don" => 0,
											"ctime" => time(),
											"ctime_search" => strtotime(date("m/d/Y",time())),
											"nid_order_status" => 1,
											//"nid_order_status_tt" => 1,
											//"nid_order_status_vc" => 1,
											"ctype" => 3, //vtp
											"niduser01" => $nid_user,
											//"nid_master" => $nid_master,
											"ddate01" => date("Y-m-d"),
											"ctime01" => date("H:i:s")
										);
										$this->db->insert("torder", $data);
										$id_cart = dbget_identity();
										$ccode_order= "VTP" . time();
										$data_code_order = array('ccode' => $ccode_order);
										$this->db->where('nid', $id_cart);
										$this->db->update('torder',$data_code_order);

						foreach ($list as $data) {
							//if($data['nid_order']==$nid_order_active) {
								$data_detail = array(
									'nid_order' => $id_cart,
									'nid_product' => $data['nid_product'],
									'nquantity' => $data['quantity'],
									'cprice' => $data['price'],
									'niscolor' => 0
								);
								$this->db->insert('torder_detail', $data_detail);
							//}
						}
						
						/*
						$thong_ke = get_thong_ke_by_user($nid_master);
							$data_thong_ke           = array(
								'cdon_trong_ngay' => $thong_ke['cdon_trong_ngay']+1,
								'ctong_don' => $thong_ke['ctong_don']+1,
								'cdoanh_thu_ngay' => $thong_ke['cdoanh_thu_ngay']+$ntotal,
								'ctong_doanh_thu' => $thong_ke['ctong_doanh_thu']+$ntotal,
						);
						$this->db->where("nid_user", $nid_master);
						$this->db->update('tthong_ke', $data_thong_ke);
						*/
					
					}
				}

			  
			  exit($response);
			  /*
			  exit(json_encode($response));
			  exit(json_encode($product));
			  exit($data);
			  exit(json_encode($data));
			  */
			}	
		}
	}

	function get_order()
    {
		if(isset($_POST['ccode'])) {
			$order = get_order_by_code($_POST['ccode']);
			$order_detail = get_order_detail($order['nid']);
			$order_detail_rs = []; 
			foreach($order_detail as $data) {
				if($data['niscolor']==1) {
					$color = get_color_byid($data['nid_product']);
					$name = get_product_name($color['nid_product']).' (<strong>Phân loại:</strong> '.$color['cname'].')';
				} else
					$name = get_product_name($data['nid_product']);
				$item = array(
					'nid_product' => $data['nid_product'],
					'iscolor' => $data['niscolor'],
					'cprice' => $data['cprice'],
					'nquantity' => $data['nquantity'],
					'cproducts' => $name
				);
				$order_detail_rs[] = $item;
			}
			
			$result = array(
				'to_name' => $order['cfullname'],
				'to_phone' => $order['cphone'],
				'ntotal' => $order['ntotal'],
				'giam_gia' => $order['cgiam_gia'],
				'nid_province' => $order['nid_province'],
				'nid_district' => $order['nid_district'],
				'nid_ward' => $order['nid_ward'],
				'caddress' => $order['caddress'],
				'order_detail' => $order_detail_rs
			);
			exit(json_encode($result));
		}
	}
	
	function update_status() {
		if(isset($_POST['table']) && isset($_POST['id']) && isset($_POST['field'])) {
			$table = $_POST['table'];
			$id = $_POST['id'];
			$field = $_POST['field'];
			
			$data = get_field_by_table($table,$id,$field);
			//exit($table.$id.$field);
			if($data==0) 
				$value = 1;
			else
				$value = 0;
			
			$this->db->where("nid", $id);
			$this->db->set($field, $value);
			$this->db->update($table);
			exit($value.'');
		}
	}
	
	function getPageSpeedScore() {
		if(isset($_POST['url'])) {
			$url = $_POST['url'];
			$apiKey = 'AIzaSyDTg60qco5vBGg_mlKaKDFiGCE9qLkE1jo';
			$endpoint = 'https://www.googleapis.com/pagespeedonline/v5/runPagespeed';
			$params = [
				'url' => $url,
				'key' => $apiKey,
			];

			$query = http_build_query($params);
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $endpoint . '?' . $query);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			$response = curl_exec($ch);
			curl_close($ch);

			$data = json_decode($response, true);
			
			if (isset($data['lighthouseResult']['categories']['performance']['score'])) {
				$score = $data['lighthouseResult']['categories']['performance']['score'] * 100;
				exit($score.'');
				//exit ("PageSpeed Score: " . $score.' / 100');
			} else {
				exit("0");
				//exit ("Error retrieving PageSpeed score.");
			}
		}
	}

/*
	function sitemap() {
		// Danh sách các URL để đưa vào sitemap
			
		$product_list = get_product_all();
		$news_list = Obj_get_news();
		$urls = [
			['loc' => base_url(), 'priority' => '1.0', 'lastmod' => '2024-08-01', 'changefreq' => 'daily', 'items' => ''],
			['loc' => base_url().'san-pham', 'priority' => '0.6', 'lastmod' => '2024-07-20', 'changefreq' => 'monthly', 'items' => $product_list],
			['loc' => base_url().'tin-tuc', 'priority' => '0.8', 'lastmod' => '2024-07-25', 'changefreq' => 'monthly', 'items' => $news_list],
			
			// Thêm các URL khác ở đây
		];

		// Tạo nội dung XML cho sitemap
		$sitemap = '<?xml version="1.0" encoding="UTF-8"?>';
		$sitemap .= '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';
		
		$i=0;
		foreach ($urls as $url) {
			$sitemap .= '<url>';
			$sitemap .= '<loc>' . htmlspecialchars($url['loc']) . '</loc>';
			$sitemap .= '<priority>' . $url['priority'] . '</priority>';
			$sitemap .= '<lastmod>' . $url['lastmod'] . '</lastmod>';
			$sitemap .= '<changefreq>' . $url['changefreq'] . '</changefreq>';
			
			if($i==1) {
				$list = $url['items'];
				foreach ($list as $item) {
					$url = base_url().get_code_sec($item['nid_material_products']).'/'.get_code_cat($item['nid_cat_products']).'/'.$item['ccode'];
					$sitemap .= '<url>';
					$sitemap .= '<loc>' . htmlspecialchars($url) . '</loc>';
					//$sitemap .= '<name>' . $item['cproducts'] . '</name>';
					$sitemap .= '<price>' . $item['fprice'] . '</price>';
					$sitemap .= '<price_sale>' . $item['fprice_sale'] . '</price_sale>';
					$sitemap .= '</url>';
				}
			} else if($i==2) {
				$list = $url['items'];
				foreach ($list as $item) {
					$url = base_url().'tin-tuc/'.$item['ccode'];
					$sitemap .= '<url>';
					$sitemap .= '<loc>' . htmlspecialchars($url) . '</loc>';
					//$sitemap .= '<name>' . $item['ctitle'] . '</name>';
					//$sitemap .= '<content>' . $item['ccontent'] . '</content>';
					$sitemap .= '</url>';
				}
			}
			$i++;
			
			$sitemap .= '</url>';
		}

		$sitemap .= '</urlset>';

		// Ghi nội dung XML vào tệp sitemap.xml
		$file = fopen('sitemap.xml', 'w');
		fwrite($file, $sitemap);
		fclose($file);
		echo "Sitemap has been generated successfully.";
	}
*/

	function sitemap() {
		// Danh sách các URL để đưa vào sitemap
		$base_url = Fstr_replace('admin/', '', base_url());
		$urls = [
			['loc' => '<a target="_blank" href="'.$base_url.'">'.$base_url.'</a>']
		];
		
		$list_sec = get_sec_all();
		foreach ($list_sec as $sec) {
			$url = $base_url.'san-pham/'.$sec['ccode'];
			$urls[] = ['loc' => '<a target="_blank" href="'.$url.'">'.$url.'</a>'];
			$list_cat = get_cat_by_sec($sec['nid']);
			foreach ($list_cat as $cat) {
				$url = $base_url.'san-pham/'.$sec['ccode'].'/'.$cat['ccode'];
				$urls[] = ['loc' => '<a target="_blank" href="'.$url.'">'.$url.'</a>'];
				$list_product = get_product_by_cat($cat['nid']);
				foreach ($list_product as $product) {
					$url = $base_url.$sec['ccode'].'/'.$cat['ccode'].'/'.$product['ccode'];
					$urls[] = ['loc' => '<a target="_blank" href="'.$url.'">'.$url.'</a>'];
				}
			}
		}
		
		// Tạo nội dung XML cho sitemap
		$sitemap = '<?xml version="1.0" encoding="UTF-8"?>';
		$sitemap .= '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';
		
		foreach ($urls as $url) {
			$sitemap .= '<url>';
			$sitemap .= '<loc>' . htmlspecialchars($url['loc']) . '</loc>';
			$sitemap .= '</url>';
		}

		$sitemap .= '</urlset>';

		// Ghi nội dung XML vào tệp sitemap.xml
		$file = fopen('sitemap.xml', 'w');
		fwrite($file, $sitemap);
		fclose($file);

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://anmydesign.com/demo/demo_142/admin/sitemap.xml');
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		$data = curl_exec ($ch);
		curl_close ($ch);
		$xml = new SimpleXMLElement($data);
		foreach ($xml->url as $url_list) {
			$url = $url_list->loc;
			echo $url.'</br>';
		}
	}
}
	