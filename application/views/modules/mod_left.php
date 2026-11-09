<?php $user = Obj_get_user_datarow(Fget_userdata('session_nid_user')); ?>
<!-- Left Sidebar  -->
        <div class="left-sidebar">
            <!-- Sidebar scroll-->
            <div class="scroll-sidebar">
                <!-- Sidebar navigation-->
                <nav class="sidebar-nav">
                    <ul id="sidebarnav">
                        <li class="nav-devider"></li>
                        <li> <a href="<?php echo base_url()?>index.php/do_home" aria-expanded="false"><i class="fa fa-tachometer"></i><span class="hide-menu">Trang chủ</span></a>
                        </li>
						<?php if($user['cisadmin']==4) { ?>
						<li> <a class="has-arrow  " href="#" aria-expanded="false"><i class="fa fa-sticky-note"></i><span class="hide-menu">Phiếu hàng hóa</span></a>
                            <ul aria-expanded="false" class="collapse">
								<li><a href="<?php echo base_url().'index.php/do_order_gui_listview'; ?>">DS Phiếu Gửi</a></li>
								<li><a href="<?php echo base_url().'index.php/do_order_nhan_listview'; ?>">DS Phiếu Nhận</a></li>
                                <li><a href="<?php echo base_url().'index.php/do_sell/' ?>">Lập Phiếu</a></li>
								<li><a href="<?php echo base_url().'index.php/do_sell_moto/' ?>">Lập Phiếu Gửi xe máy</a></li>
								<li><a href="<?php echo base_url().'index.php/do_sell_tien_pc/' ?>">Lập Phiếu Gửi tiền PC</a></li>
                            </ul>
                        </li>
						<li> <a class="has-arrow  " href="#" aria-expanded="false"><i class="fa fa-th-list"></i><span class="hide-menu">Báo cáo</span></a>
                            <ul aria-expanded="false" class="collapse">
								<li><a href="<?php echo base_url().'index.php/do_report/detail/11' ?>" class="text-success">Lệnh chuyển hàng CN</a></li>
                                <li><a href="<?php echo base_url().'index.php/do_report/detail/12' ?>" class="text-dark">Bảng kê CN</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/21' ?>" class="text-info">Doanh thu CN Ngày</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/19' ?>" class="text-warning">Doanh thu CN Tháng</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/4' ?>" class="text-dark">Hàng trả CN</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/6' ?>" class="text-danger">Tồn kho CN</a></li>
                            </ul>
                        </li>
						<?php } else { ?>
                        <li> <a class="has-arrow  " href="#" aria-expanded="false"><i class="fa fa-cog"></i><span class="hide-menu">Quản trị</span></a>
                            <ul aria-expanded="false" class="collapse">
                                <li><a href="<?php echo base_url().'index.php/do_config_listview'?>">Cấu hình</a></li>
                            </ul>
                        </li>
						<li> <a class="has-arrow  " href="#" aria-expanded="false"><i class="fa fa-user"></i><span class="hide-menu">Nhân viên</span></a>
                            <ul aria-expanded="false" class="collapse">
								<li><a href="<?php echo base_url().'index.php/do_employee_listview'?>">Quản lý nhân viên</a></li>
                                <li><a href="<?php echo base_url().'index.php/do_user_type_listview'?>">Phân quyền</a></li>
                            </ul>
                        </li>
						<?php /*<li> <a href="<?php echo base_url()?>index.php/do_order_listview" aria-expanded="false"><i class="fa fa-sticky-note"></i><span class="hide-menu">Danh sách PHH</span></a>*/ ?>
						<li> <a class="has-arrow  " href="#" aria-expanded="false"><i class="fa fa-sticky-note"></i><span class="hide-menu">Phiếu hàng hóa</span></a>
                            <ul aria-expanded="false" class="collapse">
								<li><a href="<?php echo base_url()?>index.php/do_order_listview">Danh sách PHH</a></li>
                                <li><a href="<?php echo base_url().'index.php/do_sell/' ?>">Lập Phiếu</a></li>
								<li><a href="<?php echo base_url().'index.php/do_sell_moto/' ?>">Lập Phiếu Gửi xe máy</a></li>
								<li><a href="<?php echo base_url().'index.php/do_sell_tien_pc/' ?>">Lập Phiếu Gửi tiền PC</a></li>
                            </ul>
                        </li>
						<li> <a href="<?php echo base_url()?>index.php/do_order_status_listview" aria-expanded="false"><i class="fa fa-check-square-o"></i><span class="hide-menu">Trạng thái PHH</span></a>
						<li> <a href="<?php echo base_url()?>index.php/do_customer_listview" aria-expanded="false"><i class="fa fa-users"></i><span class="hide-menu">Khách hàng</span></a></li>
						<li> <a href="<?php echo base_url()?>index.php/do_department_listview" aria-expanded="false"><i class="fa fa-building"></i><span class="hide-menu">Chi nhánh</span></a></li>
						<?php /*<li> <a href="<?php echo base_url()?>index.php/do_order_log_listview" aria-expanded="false"><i class="fa fa-history"></i><span class="hide-menu">Nhật ký Phiếu hàng hóa</span></a></li>*/ ?>
						<li> <a class="has-arrow  " href="#" aria-expanded="false"><i class="fa fa-usd"></i><span class="hide-menu">Bảng phí</span></a>
							<ul aria-expanded="false" class="collapse">
                                <li><a href="<?php echo base_url().'index.php/do_bang_phi_gui_xe_may_listview/' ?>">Phí gửi xe máy</a></li>
								<li><a href="<?php echo base_url().'index.php/do_bang_phi_gui_tien_listview/' ?>">Phí gửi tiền</a></li>
                            </ul>
						</li>
						<li> <a class="has-arrow  " href="#" aria-expanded="false"><i class="fa fa-th-list"></i><span class="hide-menu">Báo cáo</span></a>
                            <ul aria-expanded="false" class="collapse">
                                <li><a href="<?php echo base_url().'index.php/do_report/detail/1' ?>" class="text-success">Lệnh chuyển hàng Cty</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/11' ?>" class="text-success">Lệnh chuyển hàng CN</a></li>
                                <li><a href="<?php echo base_url().'index.php/do_report/detail/2' ?>" class="text-dark">Bảng kê Cty</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/12' ?>" class="text-dark">Bảng kê CN</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/15' ?>" class="text-info">Doanh thu Cty Ngày</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/16' ?>" class="text-info">Doanh thu Cty Ngày (Theo CN)</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/21' ?>" class="text-info">Doanh thu CN Ngày</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/17' ?>" class="text-warning">Doanh thu Cty Tháng</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/18' ?>" class="text-warning">Doanh thu Cty Tháng (Theo CN)</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/19' ?>" class="text-warning">Doanh thu CN Tháng</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/3' ?>">Hàng trả Cty</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/4' ?>">Hàng trả CN</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/5' ?>" class="text-danger">Tồn kho Cty</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/6' ?>" class="text-danger">Tồn kho CN</a></li>
								<?php /*
								<li><a href="<?php echo base_url().'index.php/do_report/detail/7' ?>">Số liệu Ngày</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/8' ?>">Số liệu CN Ngày</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/9' ?>">Số liệu Tháng</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/10' ?>">Số liệu CN Tháng</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/11' ?>">Thống kê điều chỉnh giảm giá?</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/12' ?>">Phí gửi tiền phát chuyển?</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/13' ?>">Phí gửi xe máy?</a></li>
								<?php /*<li><a href="<?php echo base_url().'index.php/do_report/detail/14' ?>">Kê tiền Fax?</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/19' ?>">Doanh thu năm</a></li>
								<li><a href="<?php echo base_url().'index.php/do_report/detail/20' ?>">Doanh thu CN năm</a></li>
								*/ ?>
                            </ul>
                        </li>
						<?php } ?>
                    </ul>
                </nav>
                <!-- End Sidebar navigation -->
            </div>
            <!-- End Sidebar scroll-->
        </div>
        <!-- End Left Sidebar  -->