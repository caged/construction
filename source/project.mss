Map {
  background-color: #f1f1f1;
}

#neighborhoods {
  line-width: 3;
  line-color: #000;
}

#streets {
  line-width: 1;
  line-color: #aaa;
}

#construction {
  marker-width: 6;
  marker-line-width: 0;

  [newclass='NEW CONSTRUCTION'] {
    marker-fill: #7A3AA3;
  }

  [newclass='REPLACEMENT'] {
    marker-fill: #5668DE;
  }

  [year >= 2010] {
    marker-width: 4;
  }

  [year = 2011] {
    marker-width: 5;
  }

  [year = 2012] {
    marker-width: 6;
  }

  [year = 2013] {
    marker-width: 7;
  }

  [year = 2014] {
    marker-width: 8;
  }

  [year = 2015] {
    marker-width: 9;
  }
}
