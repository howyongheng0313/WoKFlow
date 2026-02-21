<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Calendar.ascx.cs" Inherits="WokFlow.Controls.Calendar" %>

<div class="relative inline-block w-full" id="calendarWrapper_<%= ClientID %>">
    <input type="text" readonly="readonly" id="calendarInput_<%= ClientID %>"
        class="w-full h-12 px-4 bg-white/60 backdrop-blur-md border border-white/60 rounded-xl text-[#1A1A1A] font-medium cursor-pointer hover:border-[#FF8C66] transition-all"
        placeholder="Select date..." />
    <asp:HiddenField ID="hdnSelectedDate" runat="server" />

    <div id="calendarPopup_<%= ClientID %>" class="hidden absolute top-full left-0 mt-2 p-4 bg-white/90 backdrop-blur-xl border border-white/50 rounded-xl shadow-2xl z-50 w-full min-w-[300px]">
        <div class="flex gap-3 mb-4 px-1">
            <div class="relative flex-[3]">
                <select id="calMonth_<%= ClientID %>"
                    class="w-full appearance-none bg-orange-50/50 hover:bg-white border border-orange-200/50 hover:border-orange-400 rounded-lg px-3 py-2 text-sm font-semibold text-gray-700 cursor-pointer">
                    <option value="0">January</option>
                    <option value="1">February</option>
                    <option value="2">March</option>
                    <option value="3">April</option>
                    <option value="4">May</option>
                    <option value="5">June</option>
                    <option value="6">July</option>
                    <option value="7">August</option>
                    <option value="8">September</option>
                    <option value="9">October</option>
                    <option value="10">November</option>
                    <option value="11">December</option>
                </select>
            </div>
            <div class="relative flex-[2]">
                <select id="calYear_<%= ClientID %>"
                    class="w-full appearance-none bg-orange-50/50 hover:bg-white border border-orange-200/50 hover:border-orange-400 rounded-lg px-3 py-2 text-sm font-semibold text-gray-700 cursor-pointer">
                </select>
            </div>
        </div>
        <div class="grid grid-cols-7 gap-1 mb-2 border-b border-gray-100 pb-2">
            <div class="text-center text-xs font-bold text-gray-400 py-1">Su</div>
            <div class="text-center text-xs font-bold text-gray-400 py-1">Mo</div>
            <div class="text-center text-xs font-bold text-gray-400 py-1">Tu</div>
            <div class="text-center text-xs font-bold text-gray-400 py-1">We</div>
            <div class="text-center text-xs font-bold text-gray-400 py-1">Th</div>
            <div class="text-center text-xs font-bold text-gray-400 py-1">Fr</div>
            <div class="text-center text-xs font-bold text-gray-400 py-1">Sa</div>
        </div>
        <div id="calGrid_<%= ClientID %>" class="grid grid-cols-7 gap-1"></div>
    </div>
</div>

<script>
(function() {
    var cid = '<%= ClientID %>';
    var hiddenId = '<%= hdnSelectedDate.ClientID %>';
    var wrapper = document.getElementById('calendarWrapper_' + cid);
    var input = document.getElementById('calendarInput_' + cid);
    var popup = document.getElementById('calendarPopup_' + cid);
    var monthSel = document.getElementById('calMonth_' + cid);
    var yearSel = document.getElementById('calYear_' + cid);
    var grid = document.getElementById('calGrid_' + cid);
    var hidden = document.getElementById(hiddenId);

    var currentYear = new Date().getFullYear();
    for (var y = currentYear; y >= 1900; y--) {
        var opt = document.createElement('option');
        opt.value = y; opt.textContent = y;
        yearSel.appendChild(opt);
    }

    var selectedDate = hidden.value || '';
    if (selectedDate) {
        var parts = selectedDate.split('-');
        monthSel.value = parseInt(parts[1]) - 1;
        yearSel.value = parts[0];
        input.value = selectedDate;
    } else {
        monthSel.value = new Date().getMonth();
        yearSel.value = currentYear;
    }

    function render() {
        var yr = parseInt(yearSel.value), mo = parseInt(monthSel.value);
        var daysInMonth = new Date(yr, mo + 1, 0).getDate();
        var firstDay = new Date(yr, mo, 1).getDay();
        grid.innerHTML = '';
        for (var i = 0; i < firstDay; i++) {
            var empty = document.createElement('div');
            empty.className = 'h-8 w-8';
            grid.appendChild(empty);
        }
        for (var d = 1; d <= daysInMonth; d++) {
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.textContent = d;
            var dateStr = yr + '-' + String(mo + 1).padStart(2, '0') + '-' + String(d).padStart(2, '0');
            btn.setAttribute('data-date', dateStr);
            var isSelected = selectedDate === dateStr;
            btn.className = 'h-8 w-8 rounded-full text-sm font-medium flex items-center justify-center transition-all ' +
                (isSelected ? 'bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white shadow-md' : 'text-gray-700 hover:bg-orange-50 hover:text-[#FF8C66]');
            btn.addEventListener('click', function(e) {
                e.preventDefault(); e.stopPropagation();
                selectedDate = this.getAttribute('data-date');
                hidden.value = selectedDate;
                input.value = selectedDate;
                popup.classList.add('hidden');
                render();
            });
            grid.appendChild(btn);
        }
    }

    monthSel.addEventListener('change', render);
    yearSel.addEventListener('change', render);
    input.addEventListener('click', function(e) { e.stopPropagation(); popup.classList.toggle('hidden'); });
    document.addEventListener('click', function(e) { if (!wrapper.contains(e.target)) popup.classList.add('hidden'); });
    render();
})();
</script>