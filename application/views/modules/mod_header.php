<div class="container body">
      <div class="main_container">
        <div class="col-md-3 left_col">
          <div class="left_col scroll-view">
            <div class="navbar nav_title" style="border: 0;    margin-bottom: 10px;">
			  <a href="<?php echo base_url(); ?>index.php/do_home" class="site_title" style="display: flex; align-items: center; gap: 8px; padding-left: 15px;">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#26B99A" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width: 28px; height: 28px; min-width: 28px;">
        <line x1="18" y1="20" x2="18" y2="4" stroke="#1ABB9C" />
        <line x1="6" y1="20" x2="6" y2="12" />
        <rect x="14" y="7" width="8" height="9" rx="1" fill="#1ABB9C" stroke="#1ABB9C" stroke-width="1" />
        <rect x="2" y="14" width="8" height="5" rx="1" fill="#2A3F54" />
        <path d="M12 2A10 10 0 0 0 2 12" stroke-dasharray="2 2" opacity="0.5" />
        <circle cx="18" cy="11" r="1.5" fill="#2A3F54" stroke="#fff" stroke-width="1"/>
    </svg>
    
    <span style="font-weight: 800; font-size: 21px; color: #FFFFFF; letter-spacing: 1px; text-transform: uppercase; font-family: 'Helvetica Neue', Roboto, sans-serif;">
        EA HUB
    </span>
</a>
            </div>

            <div class="clearfix"></div>

            <!-- menu profile quick info -->
            <div class="profile clearfix">
              <div class="profile_pic">
                <img src="<?php echo base_url(); ?>images/user.jpg" alt="..." class="img-circle profile_img">
              </div>
              <div class="profile_info">
                <span>Xin chào,</span>
                <h2><?php echo Fget_userdata('session_user_full_name'); ?></h2>
              </div>
            </div>
            <!-- /menu profile quick info -->

            <br />

            <!-- sidebar menu -->
            <div id="sidebar-menu" class="main_menu_side hidden-print main_menu">
			  <div class="menu_section">
				<ul class="nav side-menu">
                  
				  <li>
					<a href="<?php echo base_url(); ?>index.php/do_home">
					  <i class="fa fa-dashboard"></i> Trang Chủ Dashboard
					</a>
				  </li>

				  <li>
					<a href="<?php echo base_url(); ?>index.php/do_bot_client_listview">
					  <i class="fa fa-cubes"></i> Quản Lý Tài Khoản Bot
					</a>
				  </li>

				  <li>
					<a href="<?php echo base_url(); ?>index.php/do_bot_balance_report">
					  <i class="fa fa-line-chart"></i> Thống Kê Số Dư & Quỹ
					</a>
				  </li>

				  <li>
					<a href="<?php echo base_url(); ?>index.php/do_bot_license_history">
					  <i class="fa fa-key"></i> Lịch Sử Cấp Bản Quyền
					</a>
				  </li>

				  <li>
					<a href="<?php echo base_url(); ?>index.php/do_system_log">
					  <i class="fa fa-code"></i> Nhật Ký Bảo Mật
					</a>
				  </li>

					<?php if (Fget_userdata('session_user_role') == 'admin') { ?>
				  <li>
					<a href="<?php echo base_url(); ?>index.php/do_staff_listview">
					  <i class="fa fa-user"></i> Quản Lý Tài Khoản
					</a>
				  </li>
					<?php } ?>
				  
				  <?php /*
				  <li>
					<a><i class="fa fa-sliders"></i> Thiết Lập Hệ Thống <span class="fa fa-chevron-down"></span></a>
					<ul class="nav child_menu">
					  <li><a href="<?php echo base_url(); ?>index.php/do_staff_listview">Tài Khoản Nhân Sự</a></li>
					  <li><a href="<?php echo base_url(); ?>index.php/do_system_log">Nhật Ký Bảo Mật Log</a></li>
					  <li><a href="#">Cấu Hình Bot Mặc Định</a></li>
					</ul>
				  </li>
					*/ ?>
				</ul>
			  </div>
			</div>
						<!-- /sidebar menu -->

            <!-- /menu footer buttons -->
            <div class="sidebar-footer hidden-small">
              <a data-toggle="tooltip" data-placement="top" title="Settings">
                <span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
              </a>
              <a data-toggle="tooltip" data-placement="top" title="FullScreen">
                <span class="glyphicon glyphicon-fullscreen" aria-hidden="true"></span>
              </a>
              <a data-toggle="tooltip" data-placement="top" title="Lock">
                <span class="glyphicon glyphicon-eye-close" aria-hidden="true"></span>
              </a>
              <a data-toggle="tooltip" data-placement="top" title="Logout" href="<?php echo base_url().'index.php/do_logout'?>">
                <span class="glyphicon glyphicon-off" aria-hidden="true"></span>
              </a>
            </div>
            <!-- /menu footer buttons -->
          </div>
        </div>

        <!-- top navigation -->
        <div class="top_nav">
          <div class="nav_menu">
              <div class="nav toggle">
                <a id="menu_toggle"><i class="fa fa-bars"></i></a>
              </div>
              <nav class="nav navbar-nav">
              <ul class=" navbar-right">
                <li class="nav-item dropdown open" style="padding-left: 15px;">
                  <a href="javascript:;" class="user-profile dropdown-toggle" aria-haspopup="true" id="navbarDropdown" data-toggle="dropdown" aria-expanded="false">
                    <img src="<?php echo base_url(); ?>images/user.jpg" alt=""><?php echo Fget_userdata('session_user_full_name'); ?>
                  </a>
                  <div class="dropdown-menu dropdown-usermenu pull-right" aria-labelledby="navbarDropdown">
                    <a class="dropdown-item"  href="javascript:;"> Profile</a>
                    <a class="dropdown-item"  href="<?php echo base_url().'index.php/do_logout'?>"><i class="fa fa-sign-out pull-right"></i> Đăng xuất</a>
                  </div>
                </li>
			  </ul>
            </nav>
          </div>
        </div>
        <!-- /top navigation -->