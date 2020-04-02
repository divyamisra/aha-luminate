'use strict';
(function ($) {
  $(document).ready(function () {

    //add ie11 class to body for specific styling
    var ie11 = false;
    if (ie11 = !!window.MSInputMethodContext && !!document.documentMode) {
	    $('body').addClass("ie11");
    }

    // Heart Walk 2020 Donation JS
    //Donation Levels
    // var amountLevel = readCookie('level');
    var amountLevel = null;
    // replace default radio button check if page is errored out
    jQuery('input[name="level_flexibleexpandedsubmit"]:checked').closest('.donation-level-container').addClass('active');

    if (amountLevel == null || amountLevel == "") {
       jQuery(".donation-level-container").each(function(i){
	  //remove role from radio buttons
	  jQuery(this).find('input[type=radio]').removeAttr("role");
          if (jQuery(this).find('input:checked').length > 0) {
             document.cookie="level=level"+i;
             amountLevel="level"+i;
             return;
          }
       });
    }

    $('.donation-level-container:last-child').addClass('enterAmt');
    var donateSpan = '<span class="donation-level-total-amount"></span>';
    $('.donation-level-container').each(function(i){
        $(this).addClass('level'+i);
        i++;
    });
    $(".donation-level-amount-container").each(function() {
        $(this).text($(this).text().replace(".00", ""));
    });

    //wrap recognition section
    var wrapStart = jQuery('.tr-recognition-name-view').prev('.form-row').prev('.section-header-container');
    var wrapLast = jQuery('#tr_show_gift_to_public_row').next();
    wrapStart.nextUntil(wrapLast).andSelf().wrapAll("<div class='recognition'></div>");

    $('.donation-level-container').click(function(){
        $('.donation-level-container').removeClass('active');
        $('.formMessage p').removeClass('active');
	$('.donation-level-container input[type=radio]').attr("aria-checked","false");
	$(this).find('input[type=radio]').attr("aria-checked","true");
        $(this).addClass('active');
	for (var x=0;x<10;x++) {
            if($(this).hasClass('level'+x)){
               var level = 'level'+x;
	       if($('.donation-level-container.active').hasClass('level'+x)) {
		   $('.formMessage .level'+x).addClass('active');
   	       }
	       break;
	    }
        }

	if (!ie11) {
		//check last entry to see if active
		$('.donation-level-user-entered').hide();
		if($('.enterAmt.active').hasClass('level'+x)) {
		       $('.donation-level-user-entered').show();
		}
	}

	document.cookie="level="+level;
        //var amt = $(this).find('.donation-level-amount-container').text();
        //$('.donateSubmit').text('Donate '+amt);
    });

    $('.designated-giving-recurring-row input[type=radio]:checked').closest('.designated-giving-recurring-row').addClass("active");
    $('.designated-giving-recurring-row').click(function(){
        $('.designated-giving-recurring-row').removeClass('active');
        $(this).addClass('active');
    });

    //Ask custom question about displaying their name and check or uncheck anonymous check box
    $('input[name=tr_show_name_to_public]').click(function(){
	    if ($(this).is(':checked')) {
		    $('input[name=tr_recognition_nameanonymousname]').removeAttr("checked");
		    $('.tr-recognition-name-view').show();
		    $('#tr_show_gift_to_public_row').show();
	    } else {
		    $('input[name=tr_recognition_nameanonymousname]').attr("checked","checked");
		    $('.tr-recognition-name-view').hide();
		    $('#tr_show_gift_to_public_row').hide();
	    }
    });

    for (var x=0;x<10;x++) {
	//make sure to remember values on reload
        if(amountLevel == 'level' + x) {
           $('.level' + x).addClass('active');
           $('.level' + x + ' .donation-level-label-input-container input').click();
	   break;
        }
    }

    $('.donateSubmit').click(function(){
        $('#pstep_finish').click();
    });

    $('#level_flexiblegift_type_Row .form-content fieldset legend').addClass('aural-only');
    $('#level_flexiblegift_type_Row').before("<p><strong>Would you like to donate just once or monthly?</strong></p>");

    //$('h2:contains("Matching Gift:")').wrap('<div id="matching_gift_section"></div>');
    //$('.matching-gift-container').appendTo('#matching_gift_section');
    //if matching gift section is not there, hide section title.
    if ($('.matching-gift-container').length == 0) {
	    $('h2:contains(Matching)').hide();
    }
    //$('#matching_gift_section').insertAfter('.form-donation-level');
    $('.donation-level-user-entered input').attr("placeholder","Amount").after("<div class='other-amt-note'><em>$25 minimum donation</em></div>");

    /*$('#show_employer_match_check').click(function(){
        $('#matching_gift_section').slideToggle();
        if (!$(this).is(':checked')) {
            console.log("is is now NOT checked");
            document.cookie = "ahaMatch=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/heartdev/site;";
        }
        else {
            document.cookie = "ahaMatch=true";
        }
    });
    var cookieMatch = readCookie('ahaMatch');
    if (cookieMatch == 'true') {
        console.log('the cookie is true');
        $('#show_employer_match_check').trigger('click');
    }*/

    var xname = $('#part_name_donform').text()
    if (xname != ''){
    $('#tr_show_gift_to_public_row label').text('Would you like your name displayed on '+xname+'\'s page.');
    $('#tr_recognition_nameanonymous_row label').text('Hide my name from lists on '+xname+'\'s page. \('+xname+' will still see your name regardless of your choice.\)');}

    $('.external-payment label a').text('PayPal');
    $('.internal-payment a.payment-type-label:contains(Credit)').text('Credit');
    $('.internal-payment a.payment-type-label img').closest('a').text('Swiper');
    $('.payment-type-option input').wrap('<span></span>');
    $('a.payment-type-label').keyup(function(element){
	    if (element.keyCode == 13) {
		    $(this).closest('.payment-type-option').click();
	    }
    });

    $('.level5 .donation-level-label-input-container').addClass('aural-only');

/**** impact statement randomizer *****/
      var $all = $(".impactStatement").hide();
      $(randImpactStatement($all).slice(0, 1)).show();
/***** end impact statement randomizer ****/


    /*access*/
    $('html').attr('xmlns','http://www.w3.org/1999/xhtml').attr('lang','en').attr('xml:lang','en');

    var contentMeta = $('meta[name="Keywords"]').attr('content').trim();
    $('meta[name="Keywords"]').attr('content',contentMeta);

    //$('.payment-type-label').attr('tabindex','-1');

    $('#ProcessForm').attr('name','ProcessForm');

    $('#level_flexible_row.form-row.form-donation-level').attr('id','level_flexible_row2');

    $('fieldset.cardExpGroup').prepend('<legend class="aural-only">Credit Card Expires</legend>');

    $('#level_flexible_row2').wrapInner('<fieldset></fieldset>');
    $('#level_flexible_row2 fieldset').prepend('<legend class="aural-only">Select Gift Amount</legend>');

    $('#responsive_payment_typepay_typeradio_payment_types').wrapInner('<fieldset></fieldset>');
    $('#responsive_payment_typepay_typeradio_payment_types fieldset').prepend('<legend class="aural-only">Payment options</legend>');

    $('h5.transaction-summary-header').replaceWith(function () {
        return '<h1 class="transaction-summary-header summary-section-header dividerHeading" class="section-header-text">' + $(this).html() + '</h1>';
    });

    $('#responsive_payment_typecc_numbername, #responsive_payment_typecc_cvvname, #billing_first_namename, #billing_last_namename, #billing_addr_street1name, #billing_addr_cityname, #billing_addr_zipname, #donor_email_addressname, #responsive_payment_typecc_exp_date_MONTH, #responsive_payment_typecc_exp_date_YEAR, #billing_addr_state, #billing_addr_country').attr('aria-required','true');
    $('#billing_addr_street1_row, #billing_addr_street2_row, #billing_addr_city_row, #billing_addr_state_row, #billing_addr_zip_row, #billing_addr_country_row').wrapAll('<div class="billing-fields-container"></div>');

    if ($('.errorMessageContainer .ErrorMessage.page-error .field-error-text').length > 0) {
        $('.errorMessageContainer .ErrorMessage.page-error .field-error-text').attr('role','alert');
    }
    $('#responsive_payment_typecc_numbername').attr('placeholder','XXXXXXXXXXXXXXXX');
    $('#level_flexible_row').before('<div class="required-indicator-legend"><span class="field-required"></span><span class="required-indicator-legend-text">Indicates Required</span></div>');

    $('label[for="responsive_payment_typepay_typeradiocredit"] a').attr('aria-label','PAYMENT BY CREDIT CARD');
    $('label[for="responsive_payment_typepay_typeradiopaypal"] a').attr('aria-label','PAYMENT BY PAY PAL');

    $('#responsive_payment_typepay_typeradiopaypal').attr('tabindex','-1');
    $('#responsive_payment_typepay_typeradiocredit').attr('tabindex','-1');

    /*
    $('label[for="responsive_payment_typepay_typeradiocredit"] a').click(function(e){
        e.preventDefault();
        $('label[for="responsive_payment_typepay_typeradiocredit"]').click();
    });
    $('label[for="responsive_payment_typepay_typeradiopaypal"] a').click(function(){

    });
    */

    // Adding Mark's text above matching company label
    $('#donor_matching_employer_Row').prepend('<p>Use the search box below to find out if your employer will match your donation!</p>');
    $('#donor_matching_employer_Row .form-input-label-block').addClass("aural-only");

    // Selecting empty value from the Gift Duration drop-down when the One-time Gift box is checked
    $('#level_flexiblegift_type1').click(function(){
        console.log('One-time gift box checked');
        $('#level_flexibleduration').val("");
        $('#level_flexibleduration_row').hide();
    });
    $('#level_flexiblegift_type2').click(function(){
        $('#level_flexibleduration_row').show();
    });

    // Limiting number of characters in credit card field
    $('#responsive_payment_typecc_numbername').attr('maxlength','16');

    // Change order of help link for tabbing
    $('.HelpLink').insertAfter('#responsive_payment_typecc_cvvname');

    $('span.field-required').closest('.form-content').find('input').addClass("required");

    // Moving matching gift widget to top of page if a search has been conducted
    /*if ($('#donor_matching_employer_company_information').length > 0) {
        $('#matching_gift_section').insertAfter($('h1#formTitle').parent().parent());
    }*/

    // a11y radio group for donation levels
    $('#level_flexible_row2 fieldset').attr('aria-labelledby', 'level_flexible_row2');
    $('#level_flexible_row2 fieldset').attr('role', 'radiogroup');
    $('input[name="level_flexibleexpanded"]').each(function(){
      $(this).attr({
        group: 'donation-levels',
        'aria-checked': $(this).is(':checked')
      });
    });

    //sponsor slider
    if($('.sponsor_slider .local_sponsors').length > 0){
	$('.sponsor_slider .local_sponsors').unslider({
	  selectors: {
	    container: 'div.tr_sponsorship_logos',
	    slides: 'div.tr_sponsorship_logo'
	  },
	  autoplay: true
	});
    }

    /*Thank You Page access edits */
    if (jQuery('.transaction-summary-info').length > 0) {
        jQuery('.transaction-summary-entry .entry-label').attr('tabindex','0');
        jQuery('.transaction-summary-entry .entry-value').each(function() {
            if (jQuery(this).text().length > 0) {
                jQuery(this).attr('tabindex','0');
            }
            else {
                jQuery(this).attr('tabindex','1');
            }
        });
        jQuery('.entry-label:contains("Total Gift Amount:")').attr('aria-label','Total Gift Amount');
    }


    // Google Events
    jQuery("input[name*='level_flexibleexpanded']").blur(function(){
        _gaq.push(['t2._trackEvent', 'Donation Level', 'click', 'Donation amount']);
    });
    jQuery("#donor_matching_employersearchname").blur(function(){
        _gaq.push(['t2._trackEvent', 'Employer Match', 'click', 'Employer Search']);
    });
    jQuery("#tr_show_gift_to_publicname").blur(function(){
        _gaq.push(['t2._trackEvent', 'Display Options', 'click', 'Display Amount']);
    });
    jQuery("#tr_recognition_nameanonymousname").blur(function(){
        _gaq.push(['t2._trackEvent', 'Display Options', 'click', 'Hide Name']);
    });
    jQuery("#level_flexibleduration").blur(function(){
        _gaq.push(['t2._trackEvent', 'Recurring Gift', 'click', 'Gift Duration']);
    });
    jQuery("#tr_recognition_namerec_namename").blur(function(){
        _gaq.push(['t2._trackEvent', 'Display Options', 'click', 'How to Display']);
    });
    jQuery("#responsive_payment_typecc_numbername").blur(function(){
        _gaq.push(['t2._trackEvent', 'Payment', 'click', 'Credit Card']);
    });
    jQuery("#responsive_payment_typecc_cvvname").blur(function(){
        _gaq.push(['t2._trackEvent', 'Payment', 'click', 'Credit Card Expires']);
    });
    jQuery("#billing_first_namename").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'First Name']);
    });
    jQuery("#billing_last_namename").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'Last Name']);
    });
    jQuery("#billing_addr_street1name").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'Street 1']);
    });
    jQuery("#billing_addr_street2name").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'Street 2']);
    });
    jQuery("#billing_addr_cityname").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'City']);
    });
    jQuery("#billing_addr_state").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'State']);
    });
    jQuery("#billing_addr_zipname").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'Zip']);
    });
    jQuery("#billing_addr_country").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'Country']);
    });
    jQuery("#donor_email_addressname").blur(function(){
        _gaq.push(['t2._trackEvent', 'Billing Info', 'click', 'Email']);
    });
    jQuery("input[name='donor_matching_employerradioGroup']").blur(function(){
        _gaq.push(['t2._trackEvent', 'Employer Match', 'click', 'Company']);
    });
    jQuery("#amazonPayLink a").blur(function(){
        _gaq.push(['t2._trackEvent', 'Payment', 'click', 'Amazon']);
    });
    jQuery("#modalDonationButton").blur(function(){
        _gaq.push(['t2._trackEvent', 'Donation form lightbox', 'click', 'Donate Now']);
    });
    jQuery("#cover_fee_radio_Yes").click(function(){
        if (jQuery("#cover_fee_radio_Yes").is(":checked")) {
            _gaq.push(['t2._trackEvent', 'payment', 'click', 'transaction fees yes']);
        } else {
            _gaq.push(['t2._trackEvent', 'payment', 'click', 'transaction fees no']);
        }
    });
    jQuery(".thankYouShare a:contains('Share on Facebook')").click(function(){
        _gaq.push(['t2._trackEvent', 'donor ty page', 'click', 'facebook share']);
    });
    jQuery(".thankYouShare a:contains('Share on Twitter')").click(function(){
        _gaq.push(['t2._trackEvent', 'donor ty page', 'click', 'twitter share']);
    });

    // donation form year label
    jQuery('label[for="responsive_payment_typecc_exp_date_YEAR"] span').removeClass('aural-only').text('and Year');

    jQuery('label[for="responsive_payment_typecc_exp_date_MONTH"] span').text('Expiration Date');

  });
    function randImpactStatement(array) {
      var m = array.length, t, i;
      while (m) {
        i = Math.floor(Math.random() * m--);
        t = array[m];
        array[m] = array[i];
        array[i] = t;
      }
      return array;
    }
    function readCookie(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for(var i=0;i < ca.length;i++) {
            var c = ca[i];
            while (c.charAt(0)==' ') c = c.substring(1,c.length);
            if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
        }
        return null;
    }
})(jQuery);

(function() {
    Y.use('jquery-noconflict', function() {
        jQuery(function($) {
	    //change default radio button to checkbox
	    $("#cover_fee_radio_Yes").attr("type","checkbox");
	    $('label[for=cover_fee_dropdown]').closest('.form-input-label-block').remove();

            if ($('.field-error-indicator').length) {
                if ($('#additional_amountname').val() <= 0) {
                    $("#cover_fee_radio_Yes").prop("checked", true);
                }
            }

	    $('label:contains(Cover Fee)').closest('.form-input-label-block').remove();

            if (getDonationAmount() > 0 && $('#cover_fee_radio_Yes').is(':checked')) {
               var initAmt = parseFloat(getDonationAmount());
               var toDonate =  initAmt + parseFloat((getDonationAmount() * 0.029 + .30).toFixed(2));
               $('button#pstep_finish').html("Donate $" + toDonate);
               $('.bb-additional-amount').text(toDonate)
            } else {
               var initAmt = parseFloat(getDonationAmount());
               var toDonate =  initAmt +0;
               $('button#pstep_finish').html("Donate $" + toDonate);
               $('.bb-additional-amount').text(toDonate)
	    }

            $("#cover_fee_radio_Yes").click(function() {
               if ($(this).is(':checked')) {
                  var initAmt = parseFloat(getDonationAmount());
                  var toDonate =  initAmt + parseFloat((getDonationAmount() * 0.029 + .30).toFixed(2));
                  $('button#pstep_finish').html("Donate $" + toDonate);
                  $('.bb-additional-amount').text(toDonate)
               } else {
                  $('.bb-additional-amount').text(0)
                  var initAmt = parseFloat(getDonationAmount());
                  $('button#pstep_finish').html("Donate $" + initAmt);
               }
            });
            jQuery('[id^=level_]').change(function() {
               if ($("#cover_fee_radio_Yes").is(':checked')) {
                  var initAmt = parseFloat(getDonationAmount());
                  var toDonate =  initAmt + parseFloat((getDonationAmount() * 0.029 + .30).toFixed(2));
                  $('button#pstep_finish').html("Donate $" + toDonate);
                  $('.bb-additional-amount').text(toDonate)
               } else {
                  $('.bb-additional-amount').text(0)
                  var initAmt = parseFloat(getDonationAmount());
                  $('button#pstep_finish').html("Donate $" + initAmt);
               }
            });
            $('.donation-level-user-entered input').blur(function() {
               if ($("#cover_fee_radio_Yes").is(':checked')) {
                  var initAmt = parseFloat(getDonationAmount());
                  var toDonate =  initAmt + parseFloat((getDonationAmount() * 0.029 + .30).toFixed(2));
                  $('button#pstep_finish').html("Donate $" + toDonate);
                  $('.bb-additional-amount').text(toDonate)
               } else {
                  $('.bb-additional-amount').text(0)
                  var initAmt = parseFloat(getDonationAmount());
                  $('button#pstep_finish').html("Donate $" + initAmt);
               }
            });

	    //remove validation from matching gift search
	    $('button.action-button').attr("formnovalidate","true");

            $("#ProcessForm").submit(function(e) {
                //e.preventDefault();
                if ($('#cover_fee_radio_Yes').is(':checked')) {
                    $('#additional_amountname').val(parseFloat((getDonationAmount() * 0.029 + .30).toFixed(2)));
                } else {
                    $('#additional_amountname').val(0);
                }

                $("#ProcessForm").unbind('submit');
                $('#pstep_finish').click();
            });

            $('form').validate({
                errorPlacement: function(error, element) {
			if ($(element).attr("name") == "terms-of-service-checkbox") {
				$('#terms-of-service-checkbox').closest('.form-content').after(error);
			} else {
				var placement = $(element).data('error');
				if (placement) {
					$(placement).append(error)
				} else {
					error.insertAfter(element);
				}
			}
                }
            });
	    $('#pstep_finish').click(function(){
		    if ($('input[name=donor_matching_employersearchBtn]').val() == "Search") {
			    return true;
		    } else {
			    if ($('form').valid()) {
				    return true;
			    } else {
				    return false;
			    }
		    }
	    });
        });
    });
})();

function getDonationAmount() {
	//get selected amount from checkbox
	var amt = jQuery('[id^=level_]:checked').closest('.donation-level-container').find('label').html();
	if (amt === null || amt == undefined || amt.indexOf("Enter an Amount") > -1) {
		amt = jQuery('[id^=level_flexible]:checked').parent().parent().find('input[id$="amount"]').val();
		if (amt === null) {
			amt = 0;
		}
	}
	//Convert currency string to number
	amt = Number(amt.replace(/[^0-9\.]+/g, ""));
	//console.log(amt);
	return amt;
}
