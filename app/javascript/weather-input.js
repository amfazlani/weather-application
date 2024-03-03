import { Toast } from 'bootstrap'

$( document ).on('turbolinks:load', function() {
  var debouncedFunction = debounce(function() {
    getData()
  }, 500);

  $('#inputlg').keydown(debouncedFunction); // This is the line you want!

   $(document).on('click', '.card-title', function() {
    fetchWeatherData(this)
  });

  var toastElList = [].slice.call(document.querySelectorAll('.toast'))
  var toastList = toastElList.map(function (toastEl) {
    return new Toast(toastEl, {})
  })

  window.showErrorToast = showErrorToast;
})

function getData() {
  let query = $('#inputlg').val()

  var url = '/weather?q=' + encodeURIComponent(query);

  fetch(url, {
      method: 'GET',
      headers: {
          'Accept': 'application/json',
      },
  }).then(response => response.json()).then(json => {
    if (json['errors']) {
      window.showErrorToast(json['errors'])
    } else {
      if (Array.isArray(json)) {
        for (let i = 0; i < json.length; i++) {
          let element = `<div class="card-body">
          Location: <h5 class="card-title" data-lat=${json[i].lat} data-lon=${json[i].lon}>${json[i].name}</h5>
          </div>`

          element = $('#found-locations').append(element)
        }
      } else {
        let element = `<div class="card-body">
        Location: <h5 class="card-title" data-lat=${json.lat} data-lon=${json.lon}>${json.name}</h5>
        </div>`

        $('#found-locations').append(element)
      }
    }
  }).catch((error) => {
    console.log(error)
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

  var url = `/weather/data?lat=${lat}&lon=${lon}`;

  fetch(url, {
    method: 'GET',
    headers: {
        'Accept': 'application/json',
    },
  })
  .then(response => response.json())
  .then(json => {
    element = `<div class="card-body">
      <h5 class="card-title">Current Temperature: ${json.main['temp']} degrees</h5>
      <p class="card-text">Feels like ${json.main['feels_like']}</p>
    </div>`

    $('#weather-cards').append(element)
  }).catch(()=>{
    console.log(error)
  });
}

function showErrorToast(error) {
  let toastEl = $('.toast')[0]

  let element = $('#weather-error-toaster-body')[0]

  element.innerHTML = error

  let toastInstance = Toast.getInstance(toastEl) // Returns a Bootstrap toast instance

  toastInstance.show();
}
