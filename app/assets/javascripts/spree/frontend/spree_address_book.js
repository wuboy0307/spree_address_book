//= require ./jquery.twzipcode

(function ($) {

    if ($(".adistrict").length > 0) {
        $(".adistrict").twzipcode(a_json);
        $('[name="address[zipcode]"]').hide();
    }

    function setAddress($select) {
        var $parent = $select.parents("#billing, #shipping");
        var $selected = $select.children(":selected");
        var address1 = $selected.data("address1");
        var zipcode = $selected.data("zipcode");
        var city = $selected.data("city");
        var district = $selected.data("district");
        var fullname = $selected.data("full-name");
        var phone = $selected.data("phone");

        $parent.find("[name$='[address1]']").val(address1);
        $parent.find("[name$='[fullname]']").val(fullname);
        $parent.find("[name$='[full_name]']").val(fullname);
        $parent.find("[name$='[phone]']").val(phone);
        $parent.find("[name$='[zipcode]']").val(zipcode);
        $parent.find("[name$='[city]']").children("option[value='"+ city +"']").attr("selected", true);
        $parent.find("[name$='[city]']").change();
        $parent.find("[name$='[district]']").children("option[value='"+ district +"']").attr("selected", true);
        $parent.find("[name$='[district]']").change();
    }

    $(document).ready(function () {
        var $bill_address = $("[name='order[bill_address_id]']");
        if ($bill_address.length > 0) {
            $bill_address.change(function() {
                setAddress($bill_address);
            });
        }

        var $ship_address = $("[name='order[ship_address_id]']");
        if ($ship_address.length > 0) {
            $ship_address.change(function() {
                setAddress($ship_address);
            });
        }
    });

})(jQuery);
