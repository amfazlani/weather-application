import { Toast } from 'bootstrap'

$( document ).on('turbolinks:load', function() {
  initializeToasts();
  setLocationListener();
  setKeydownListeners(debounce(fetchLocationData, 500));

  window.showErrorToast = showErrorToast;
  window.constructLocationElement = constructLocationElement
})

function getData(url, query) {
  fetch(url, {
    method: 'GET',
    headers: {
      'Accept': 'application/json',
    },
  }).then(response => response.json()).then(json => {
    if (json && json['errors']) {
      window.showErrorToast(json['errors'])
    } else {
      $('#found-locations').empty()
      $('#weather-cards').empty()

      if (Array.isArray(json)) {
        for (let i = 0; i < json.length; i++) {
          let element = window.constructLocationElement(json[i])
          element = $('#found-locations').append(element)
        }
      } else {
        let element = window.constructLocationElement(json)

        $('#found-locations').append(element)
      }
    }
  }).catch(() => {
    window.showErrorToast('Oops something went wrong!')
  });
}

function debounce(func, wait, immediate) {
  var timeout;

  return function executedFunction() {
    var context = this;
    var args = arguments;
      
    var later = function() {
      timeout = null;
      if (!immediate) func.apply(context, args);
    };

    var callNow = immediate && !timeout;
  
    clearTimeout(timeout);

    timeout = setTimeout(later, wait);
  
    if (callNow) func.apply(context, args);
  }
};

function fetchWeatherData(element) {
  let lat = element.dataset.lat
  let lon = element.dataset.lon
  let url = `/weather/data?lat=${lat}&lon=${lon}`;

  fetch(url, {
    method: 'GET',
    headers: {
      'Accept': 'application/json',
    },
  }).then(response => response.json()).then(json => {
    $('#weather-cards').empty()

    element = `<div class="card weather-card">
    <img src=${json['icon']} alt="weather icon" class="weather-icon">
    <div class="card-body">
      <h5 class="card-title">${json['data'].main['temp']} °F</h5>
      <div class="weather-subdata">
        <div> <span class="title">Feels Like:</span> <p class="value">${json['data'].main['feels_like']} °F</p> </div>
        <div> <span class="title">Max:</span> <p class="value"> ${json['data'].main['temp_max']} °F</p></div>
        <div> <span class="title">Min:</span> <p class="value"> ${json['data'].main['temp_min']} °F</p></div>
      </div>
    </div>
    </div>`

    debugger

    $('#weather-cards').append(element)
  }).catch((error)=>{
    window.showErrorToast(error)
  });
}

function showErrorToast(error) {
  let toastEl = $('.toast')[0];
  let element = $('#weather-error-toaster-body')[0];
  let toastInstance = Toast.getInstance(toastEl); // Returns a Bootstrap toast instance

  element.innerHTML = error

  toastInstance.show();
}

function initializeToasts() {
  let toastElList = [].slice.call(document.querySelectorAll('.toast'))
  let toastList = toastElList.map(function (toastEl) {
    return new Toast(toastEl, {})
  })
}

function fetchLocationData() {
  let url;
  let query = $(this).val();

  if (query == "") {
    $('#found-locations').empty()
    $('#weather-cards').empty()

    return
  }

  if ($(this).attr('id') == 'inputlg-zip') {
    url = '/weather?zip=' + encodeURIComponent(query);
  } else {
    url = '/weather?city=' + encodeURIComponent(query);
  }

  getData(url, query)
}

function setKeydownListeners(debouncedFunction) {
  $('#inputlg-zip').keydown(debouncedFunction);
  $('#inputlg-city').keydown(debouncedFunction);
}

function setLocationListener() {
  $(document).on('click', '.location-title', function() {
    fetchWeatherData(this)
  });
}

function constructLocationElement(json) {
  return `<div class="card-container col-sm-12 col-md-3 mb-2">
            <div class="card location" style="width: 18rem;">
              <i class="fa-solid fa-location-dot"></i>
              <div class="card-body">
                <h5 class="card-title">${json.name}, ${json.state}, ${json.country}</h5>
                <button class="btn btn-primary location-title" data-lat=${json.lat} data-lon=${json.lon}>View Forcast Data</button>
              </div>
            </div>
          </div>`
}
