<?php 
	$this->load->view('header');
	$this->load->view('header_end');
	$this->load->view('modules/mod_header'); 
?>


<style>
.x_panel {
    height: calc(100vh - 110px);
	text-align:center;
}
</style>
<!-- page content -->
			<div class="right_col" role="main">
				<div class="">
					
					<div class="row">
						<div class="col-md-12 col-sm-12 pd0">
							<div class="x_panel">
									
<h1 class="w3-jumbo w3-animate-top w3-center"><code>Access Denied</code></h1>
<hr class="w3-border-white w3-animate-left" style="margin:auto;width:50%">
<h3 class="w3-center w3-animate-right">Truy cập bị từ chối. Vui lòng liên hệ Admin</h3>
<h3 class="w3-center w3-animate-zoom">🚫🚫🚫🚫</h3>
<h6 class="w3-center w3-animate-zoom">error code:403 forbidden</h6>

							</div>
						</div>
					</div>

					
				</div>
			</div>
			<!-- /page content --> 
<?php
	$this->load->view('modules/mod_footer');
	$this->load->view('footer');
?>