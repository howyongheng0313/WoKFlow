<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CountrySelector.ascx.cs" Inherits="WokFlow.Controls.CountrySelector" %>

<div class="relative inline-block w-full" id="countryWrapper_<%= ClientID %>">
    <input type="text" readonly="readonly" id="countryDisplay_<%= ClientID %>"
        class="w-full h-12 px-4 bg-white/60 backdrop-blur-md border border-white/60 rounded-xl text-[#1A1A1A] font-medium cursor-pointer hover:border-[#FF8C66] transition-all"
        placeholder="Select country..." />
    <asp:HiddenField ID="hdnSelectedCountry" runat="server" />

    <div id="countryPopup_<%= ClientID %>" class="hidden absolute top-full left-0 mt-2 bg-white/90 backdrop-blur-xl border border-white/50 rounded-xl shadow-2xl z-50 w-full overflow-hidden flex flex-col max-h-[400px]">
        <div class="p-3 border-b border-gray-100 bg-white/50">
            <div class="relative">
                <i data-lucide="search" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4"></i>
                <input type="text" id="countrySearch_<%= ClientID %>" placeholder="Search country..."
                    class="w-full h-10 pl-9 pr-4 bg-orange-50/50 border border-transparent rounded-lg text-sm text-[#1A1A1A] placeholder:text-gray-400 focus:outline-none focus:bg-white focus:border-[#FF8C66] focus:ring-2 focus:ring-[#FF8C66]/20 transition-all" />
            </div>
        </div>
        <div id="countryList_<%= ClientID %>" class="flex-1 overflow-y-auto py-1" style="max-height:340px;"></div>
    </div>
</div>

<script>
(function() {
    var cid = '<%= ClientID %>';
    var hiddenId = '<%= hdnSelectedCountry.ClientID %>';
    var wrapper = document.getElementById('countryWrapper_' + cid);
    var display = document.getElementById('countryDisplay_' + cid);
    var popup = document.getElementById('countryPopup_' + cid);
    var searchInput = document.getElementById('countrySearch_' + cid);
    var listEl = document.getElementById('countryList_' + cid);
    var hidden = document.getElementById(hiddenId);

    // Country list (Arranged based on alphabet)
    var countries = [
        "Afghanistan","Albania","Algeria","Andorra","Angola","Antigua and Barbuda","Argentina","Armenia","Australia","Austria","Azerbaijan",
        "Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bhutan","Bolivia","Bosnia and Herzegovina","Botswana","Brazil","Brunei","Bulgaria","Burkina Faso","Burundi",
        "Cabo Verde","Cambodia","Cameroon","Canada","Central African Republic","Chad","Chile","China","Colombia","Comoros","Costa Rica","Croatia","Cuba","Cyprus","Czechia",
        "Denmark","Djibouti","Dominica","Dominican Republic",
        "Ecuador","Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Ethiopia",
        "Fiji","Finland","France",
        "Gabon","Gambia","Georgia","Germany","Ghana","Greece","Grenada","Guatemala","Guinea","Guinea-Bissau","Guyana",
        "Haiti","Honduras","Hungary",
        "Iceland","India","Indonesia","Iran","Iraq","Ireland","Israel","Italy",
        "Jamaica","Japan","Jordan",
        "Kazakhstan","Kenya","Kiribati","Kuwait","Kyrgyzstan",
        "Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg",
        "Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Marshall Islands","Mauritania","Mauritius","Mexico","Micronesia","Moldova","Monaco","Mongolia","Montenegro","Morocco","Mozambique","Myanmar",
        "Namibia","Nauru","Nepal","Netherlands","New Zealand","Nicaragua","Niger","Nigeria","North Korea","North Macedonia","Norway",
        "Oman",
        "Pakistan","Palau","Palestine","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal",
        "Qatar",
        "Romania","Russia","Rwanda",
        "Saint Kitts and Nevis","Saint Lucia","Saint Vincent and the Grenadines","Samoa","San Marino","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Korea","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Sweden","Switzerland","Syria",
        "Tajikistan","Tanzania","Thailand","Timor-Leste","Togo","Tonga","Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Tuvalu",
        "Uganda","Ukraine","United Arab Emirates","United Kingdom","United States of America","Uruguay","Uzbekistan",
        "Vanuatu","Venezuela","Vietnam",
        "Yemen",
        "Zambia","Zimbabwe"
    ];

    var selected = hidden.value || '';
    if (selected) display.value = selected;

    function render(filter) {
        var term = (filter || '').toLowerCase();
        var filtered = term ? countries.filter(function(c) { return c.toLowerCase().indexOf(term) !== -1; }) : countries;
        listEl.innerHTML = '';

        if (filtered.length === 0) {
            listEl.innerHTML = '<div class="p-8 text-center text-gray-400 text-sm">No countries found</div>';
            return;
        }

        filtered.forEach(function(c) {
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'w-full text-left px-4 py-2.5 text-sm font-medium transition-colors flex items-center justify-between ' +
                (selected === c ? 'bg-orange-50 text-[#FF8C66]' : 'text-gray-700 hover:bg-gray-50 hover:text-[#1A1A1A]');
            btn.innerHTML = '<span>' + c + '</span>' + (selected === c ? '<div class="w-2 h-2 rounded-full bg-[#FF8C66]"></div>' : '');
            btn.addEventListener('click', function() {
                selected = c; hidden.value = c; display.value = c;
                popup.classList.add('hidden');
                render('');
            });
            listEl.appendChild(btn);
        });
    }

    searchInput.addEventListener('input', function() { render(this.value); });
    display.addEventListener('click', function(e) {
        e.stopPropagation();
        popup.classList.toggle('hidden');
        if (!popup.classList.contains('hidden')) { searchInput.focus(); render(searchInput.value); }
    });
    document.addEventListener('click', function(e) { if (!wrapper.contains(e.target)) popup.classList.add('hidden'); });
    render('');
})();
</script>