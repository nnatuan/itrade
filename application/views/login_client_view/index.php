<?php 
	$this->load->view('header');
?>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@500;700;800&display=swap" rel="stylesheet">
<style>
        body.qcare-login-body {
            background: #0f172a !important; 
            font-family: "Helvetica Neue", Roboto, Arial, sans-serif;
            margin: 0;
            padding: 0;
            height: 100vh;
            overflow: hidden;
        }

        /* Khung chia đôi màn hình hiện đại (Split Screen) */
        .qcare-login-container {
            display: flex;
            height: 100vh;
            width: 100vw;
        }

        /* Mảng thương hiệu bên trái - Chiếm 60% */
        .qcare-login-brand-side {
            flex: 0 0 60%;
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
            border-right: 1px solid #334155;
        }

        /* Lớp pattern mạng lưới lưới Matrix Grid ẩn phía sau */
        .qcare-login-brand-side::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background-image: url('https://www.transparenttextures.com/patterns/grid-me.png');
            opacity: 0.08;
        }

        .qcare-brand-content {
            position: relative;
            z-index: 2;
            color: #ffffff;
            max-width: 520px;
        }

        .qcare-brand-content h2 {
            font-size: 42px;
            font-weight: 800;
            margin-bottom: 20px;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            color: #1abb9c; 
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .qcare-brand-content p {
            font-size: 15px;
            line-height: 1.7;
            color: #94a3b8;
            opacity: 0.9;
        }

        /* Khối Form đăng nhập bên phải - Chiếm 40% */
        .qcare-login-form-side {
            flex: 0 0 40%;
            background: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 50px;
            box-shadow: -10px 0 30px rgba(0,0,0,0.2);
        }

        .qcare-login-box {
            width: 100%;
            max-width: 360px;
        }

        /* Tinh chỉnh Header khối login */
        .qcare-login-header {
            margin-bottom: 35px;
            text-align: center;
        }

        .qcare-login-header h3 {
			font-family: "Inter", "Montserrat", "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
			font-weight: 800;
			color: #0f172a;
			margin-top: 0;
			margin-bottom: 8px;
			font-size: 26px;
			letter-spacing: 0.5px;
		}

        .qcare-login-header span {
            color: #64748b;
            font-size: 14px;
            font-weight: 500;
        }

        /* Đóng gói ô nhập liệu kèm Icon đồng bộ */
        .qcare-input-group {
            position: relative;
            margin-bottom: 20px;
        }

        .qcare-input-group i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 16px;
            transition: color 0.3s;
        }

        .qcare-input-group .form-control {
            padding-left: 45px !important;
            height: 48px !important;
            border-radius: 6px !important;
            border: 1px solid #cbd5e1 !important;
            box-shadow: none !important;
            font-size: 14px !important;
            color: #0f172a !important;
            background: #f8fafc !important;
            transition: all 0.3s;
        }

        .qcare-input-group .form-control:focus {
            border-color: #1abb9c !important;
            background: #ffffff !important;
            box-shadow: 0 0 0 3px rgba(26, 187, 156, 0.1) !important;
        }

        .qcare-input-group .form-control:focus + i {
            color: #1abb9c;
        }

        /* Nút submit đăng nhập công nghệ cao */
        .btn-qcare-login {
            width: 100%;
            height: 48px;
            background: #1abb9c !important;
            border: 1px solid #1abb9c !important;
            color: #ffffff !important;
            border-radius: 6px !important;
            font-size: 15px !important;
            font-weight: 700 !important;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 10px;
            box-shadow: 0 4px 14px rgba(26, 187, 156, 0.3) !important;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .btn-qcare-login:hover {
            background: #16a085 !important;
            border-color: #16a085 !important;
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(26, 187, 156, 0.4) !important;
        }

        /* Chân khối Form chứa logo */
        .qcare-login-footer {
            margin-top: 40px;
            border-top: 1px solid #f1f5f9;
            padding-top: 25px;
            text-align: center;
        }

        .qcare-login-footer p {
            font-size: 12px;
            color: #94a3b8;
            margin: 0;
            font-weight: 500;
            letter-spacing: 0.3px;
        }

        /* Cấu trúc Responsive cho thiết bị di động */
        @media (max-width: 991px) {
            .qcare-login-brand-side {
                display: none;
            }
            .qcare-login-form-side {
                flex: 0 0 100%;
                padding: 30px;
                background: #0f172a; 
            }
            .qcare-login-header h3 { color: #ffffff; }
            .qcare-login-header span { color: #94a3b8; }
            .qcare-input-group .form-control { background: #1e293b !important; border-color: #334155 !important; color: #fff !important;}
            .qcare-input-group .form-control:focus { background: #0f172a !important; }
        }
</style>

<body class="qcare-login-body">
    <div class="qcare-login-container">
        
        <div class="qcare-login-brand-side">
            <div class="qcare-brand-content">
                <h2>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width: 42px; height: 42px;">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                    </svg>
                    CLIENT PORTAL
                </h2>
                <p>Cổng thông tin dành riêng cho nhà đầu tư. Trực tiếp theo dõi thông số cấu hình chiến lược, kiểm soát trạng thái giao dịch và kích hoạt chế độ đóng ngắt Robot khẩn cấp mọi lúc, mọi nơi.</p>
            </div>
        </div>
        
        <div class="qcare-login-form-side">
            <div class="qcare-login-box">
                
                <div class="qcare-login-header">
                    <h3>CỔNG KHÁCH HÀNG</h3>
                    <span>Đăng nhập hệ thống giám sát Bot</span>
                </div>

                <form action="<?php echo isset($link_page) ? $link_page : base_url().'index.php/do_login_client'; ?>" method="post" name="frm_login_client" id="frm_login_client">
                    <?php if (!empty($error_message)): ?>
                        <div class="alert alert-danger" style="padding: 10px 14px; font-size: 13px; border-radius: 6px; margin-bottom: 20px; background-color: #fef2f2; color: #991b1b; border: 1px solid #fca5a5;">
                            <i class="fa fa-exclamation-triangle"></i> <?php echo $error_message; ?>
                        </div>
                    <?php endif; ?>
					
                    <div class="qcare-input-group">
                        <input type="text" name="txt_user_name" value="<?php echo isset($txt_user_name) ? $txt_user_name : ''; ?>" class="form-control" placeholder="Tên đăng nhập Bot" required="" autocomplete="off" />
                        <i class="fa fa-user"></i>
                    </div>
                    
                    <div class="qcare-input-group">
                        <input type="password" name="txt_password" class="form-control" placeholder="Mật khẩu" required="" />
                        <i class="fa fa-lock"></i>
                    </div>
                    
                    <div>
                        <button type="button" class="btn btn-qcare-login" name="btn_login" 
                                onclick="document.getElementById('hidden_button').value='btn_login'; document.getElementById('frm_login_client').submit();">
                            <i class="fa fa-sign-in"></i> ĐĂNG NHẬP VÀO TRONG
                        </button>
                    </div>

                    <div class="clearfix"></div>
                    
                    <div class="qcare-login-footer">
                        <p>EA MATRIX CLIENT PORTAL &copy; 2026</p>
                    </div>

                    <input type="hidden" name="hidden_button" id="hidden_button" value="" />
                </form>

            </div>
        </div>
	</div>	

<script src="<?php echo base_url(); ?>js/js.js"></script>	
<?php	
	$this->load->view('footer');
?>