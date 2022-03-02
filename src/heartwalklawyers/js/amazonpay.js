(function ($) {

	$.extend({
		getCustomQuerystring: function(url, name){
		  url = url.replace(new RegExp('&amp;', 'g'),'&');
		  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
		  var regexS = "[\\?&]" + name + "=([^&#]*)";
		  var regex = new RegExp(regexS);
		  var results = regex.exec(url);
		  if(results == null)
			return "";
		  else
			return decodeURIComponent(results[1].replace(/\+/g, " "));
		}
	});
})(jQuery);

/* amazon pay code here */
var default_path = "https://www2.heart.org";
jQuery(document).ready(function(){
  if (location.href.indexOf("dev2") > 0) {
    default_path = "https://dev2.heart.org";
  }
  if (location.href.indexOf("pg=personal") > 0 || location.href.indexOf("pg=team") > 0) {
		addPaymentOptions();
	}
	if (location.href.indexOf("pagename=heartwalk_participant_center") > 0) {
		addPCPaymentOptions();
	}
	if (location.href.indexOf("Donation2") > 0) {
		if (jQuery.getCustomQuerystring(location.href,"paypal") == "true") {
			setTimeout(function(){jQuery('label[for=responsive_payment_typepay_typeradiopaypal]').trigger('click');},2000);
		}
	}
});

function addPaymentOptions() {
	if (jQuery('a#sidebar_donate_button').length > 0) {
		var fr_id = jQuery.getCustomQuerystring(location.href,"fr_id");
		var teamid = jQuery.getCustomQuerystring(location.href,"team_id");
		var px = jQuery.getCustomQuerystring(location.href,"px");
    
    		/* personal page */
		if (jQuery('body.pg_personal').length > 0) {
			// var dlink = jQuery('a#sidebar_donate_button').attr("href");
			var dlink = jQuery('.js--personal-don-submit').data('final-don-url');
			console.log('custom pay on personal');
			var html = "<div class='paymentSelType text-center hidden mt-4'><h2 class='h5 mb-3'>How would you like to donate?</h2>" +
  				"<div class='d-lg-flex justify-content-lg-between'><a href='"+dlink+"' class='js--cc-btn'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards'/></a>" +
  				"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_amazon.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='amazon'><img src='https://www2.heart.org/images/content/pagebuilder/amazon-payments.png' alt='Donate with Amazon Pay'/></a>" +
  				"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_googlepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='googlepay'><img src='https://www2.heart.org/donation-forms/donatenow/images/googlepay-button.png' alt='Donate with Google Pay'/></a>" +
				"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_applepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay'/></a>" +
				"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_venmo.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo'/></a>" +
			    	"<a href='"+dlink+"&paypal=true' class='js--paypal-btn'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png'/ alt='Donate with PayPal'></a></div>";
		
			jQuery('.buttons-row').after(html);

			// add front end validation
			var parsleyOptions = {
				successClass: 'is-valid',
				errorClass: 'is-invalid',
				errorsWrapper: '<div class="invalid-feedback row"></div>',
				errorTemplate: '<div class="col-12"></div>',
				errorsContainer: function (_el) {
          return _el.$element.closest('form').find('.error-row');
        }
			};

			jQuery('.js--personal-don-form').parsley(parsleyOptions);
			
			cd.resetValidation = function () {
				jQuery('.js--personal-don-form').parsley().reset();
			}

			jQuery('input[name=personalDonAmt]').change(function () {
				var isOtherSelected = jQuery(this).hasClass('other-amt-radio');
				console.log('isOtherSelected: ', isOtherSelected);
				switch (isOtherSelected) {
						// If hidden "other" radio is selected, make other field required
						case true:
								jQuery('#personalOtherAmt').attr("required", "required");
								break;
						default:
								jQuery('#personalOtherAmt').removeAttr("required");
								break;
				}
				cd.resetValidation();
		});

			jQuery('.js--personal-don-form').submit(function(e){
				e.preventDefault();
				var form = jQuery(this);
				form.parsley().validate();
				if (form.parsley().isValid()) {
					console.log('form is valid');
					// redirect to donation form
					var updatedDlink = jQuery('.js--personal-don-submit').attr('data-final-don-url');
					jQuery('.js--cc-btn').attr('href', updatedDlink);
					var updatedPPdlink = updatedDlink + '&paypal=true';
					jQuery('.js--paypal-btn').attr('href', updatedPPdlink);
					jQuery('.tr-page-container .paymentSelType').removeClass('hidden');
					jQuery('.tr-page-container .paymentSelType').slideDown();
					return false;
				} else {
					console.log('form is NOT valid');
				}
			});

		}

    		/* team page */
		// if (jQuery('body.pg_team').length > 0) {
		// 	var dlink = jQuery('a#sidebar_donate_button').attr("href");
  	// 		var html = "<div class='paymentSelType text-center hidden'><h4>How would you like to donate?</h2>"+
		//   			"<a href='"+dlink+"'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards'/></a>" +
		//   			"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_amazon.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+teamid+"&PROXY_TYPE=22' class='amazon'><img src='https://www2.heart.org/images/content/pagebuilder/amazon-payments.png' alt='Donate with Amazon Pay'/></a>" +
		// 			"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_applepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+teamid+"&PROXY_TYPE=22' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay'/></a>" +
		// 			"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_venmo.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+teamid+"&PROXY_TYPE=22' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo'/></a>" +
		//   			"<a href='"+dlink+"&paypal=true'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png'/ alt='Donate with PayPal'></a>" +
		//     		 "</div>";
		// 	jQuery('a#sidebar_donate_button').closest('div').after(html);
		// 	jQuery('a#sidebar_donate_button').click(function(){
		// 		jQuery('#team_page > div.side-bar > div.paymentSelType').removeClass('hidden');
		// 		jQuery('.side-bar .paymentSelType').slideDown();
		// 		return false;
		// 	});
		// 	jQuery('a#main_donate_button').closest('div').after(html);
		// 	jQuery('a#main_donate_button').click(function(){
		// 		jQuery('#team_page_main_content > div.paymentSelType').removeClass('hidden');
		// 		jQuery('#team_page_main_content .paymentSelType').slideDown();
		// 		return false;
		// 	});
		// }
	} else {
		setTimeout(addPaymentOptions,500);
	}
}

function addPCPaymentOptions() {
	if (jQuery('a#make_a_donation').length > 0) {
		var fr_id = jQuery.getCustomQuerystring(location.href,"fr_id");
		var teamid = jQuery.getCustomQuerystring(location.href,"team_id");
		var px = jQuery.getCustomQuerystring(location.href,"px");
	  
		if (location.href.indexOf("pagename=heartwalk_participant_center") > 0) {
		 	jQuery('.profile_box_row').css({"display":"flex"});
			var dlink = jQuery('a#make_a_donation').attr("href");
			var px = jQuery('body').data("cons-id");
			var html = "<div class='paymentSelType hidden' style='clear:both;padding-top:20px;'>" +
						 "<h7>How would you like to donate?</h7>" +
						 "<a href='"+dlink+"'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards'/></a>" +
						 "<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_amazon.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='amazon'><img src='https://www2.heart.org/images/content/pagebuilder/amazon-payments.png' alt='Donate with Amazon Pay'/></a>" +
      				                 "<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_googlepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='googlepay'><img src='https://www2.heart.org/donation-forms/donatenow/images/googlepay-button.png' alt='Donate with Google Pay'/></a>" +
 			                         "<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_applepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay'/></a>" +
						 "<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_venmo.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo'/></a>" +
						 "<a href='"+dlink+"&paypal=true'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png'/ alt='Donate with PayPal'></a>" +
						 "</div>";
			jQuery('a#make_a_donation').closest('.profile_box').append(html);
			jQuery('a#make_a_donation').click(function(e){
				e.preventDefault();
				jQuery('#personal_page_main_content > div.paymentSelType').removeClass('hidden');
				jQuery('.paymentSelType').slideDown();
				return false;
			});		  
		}

	} else {
		setTimeout(addPCPaymentOptions,500);
	}
}

function addPaymentTypesOnSearch() {
	jQuery('a:contains(Donat)').on('click',function(e){
		e.preventDefault();
		if(!jQuery(this).hasClass('js--team-member-donate')){
			if (jQuery(this).next('.paymentSelType').length > 0) {
				jQuery(this).next('.paymentSelType').remove();
			} else {
				var dlink = jQuery(this).attr("href");
				var fr_id = jQuery.getCustomQuerystring(dlink,"FR_ID");
				var px = jQuery.getCustomQuerystring(dlink,"PROXY_ID");
				var pt = jQuery.getCustomQuerystring(dlink,"PROXY_TYPE");
	
				var html = "<div class='paymentSelType text-center' style='padding-top:10px;'>" +
					"<h2 class='h6'>How would you like to donate?</h2>" +
					"<div class='payment-options-container'><a href='"+dlink+"'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards'/></a>" +
					"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_amazon.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE="+pt+"' class='amazon'><img src='https://www2.heart.org/images/content/pagebuilder/amazon-payments.png' alt='Donate with Amazon Pay'/></a>" +
  				        "<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_googlepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE="+pt+"' class='googlepay'><img src='https://www2.heart.org/donation-forms/donatenow/images/googlepay-button.png' alt='Donate with Google Pay'/></a>" +
				        "<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_applepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE="+pt+"' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay'/></a>" +
					"<a href='"+default_path+"/site/SPageNavigator/heartwalk_donate_venmo.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE="+pt+"' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo'/></a>" +
					"<a href='"+dlink+"&paypal=true'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png'/ alt='Donate with PayPal'></a></div>";
				jQuery(this).after(html);
			}
		}
	});
}
