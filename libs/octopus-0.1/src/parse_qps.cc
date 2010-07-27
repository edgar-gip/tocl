// Copyright (C) 2010 Edgar Gonzàlez i Pellicer <ausias.et.al@gmail.com>
//
// This file is part of octopus-0.1.
//
// octopus is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// octopus is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
// 
// You should have received a copy of the GNU General Public License
// along with octopus; see the file COPYING.  If not, see
// <http://www.gnu.org/licenses/>.

#include <cctype>
#include <exception>
#include <fstream>
#include <iostream>
#include <map>
#include <string>

#include <octave/oct.h>

#ifdef HAVE_CONFIG_H
#include "undefs.h"
#include "config.h"
#endif

using namespace std;


/*********************/
/* Trimmed substring */
/*********************/

static string trimmed_substr(const string& _string,
			     string::size_type _start, string::size_type _end) {
  // Result
  string result;

  // Bound
  if (_string.size() < _end)
    _end = _string.size();

  // Skip starting space
  while (_start < _end and isspace(_string[_start]))
    ++_start;

  // No space
  while (_start < _end and not isspace(_string[_start]))
    result += _string[_start++];

  // Return
  return result;
}


/****************************************************************/
/* Parse a QPS file                                             */
/* Following                                                    */
/* - http://lpsolve.sourceforge.net/5.5/mps-format.htm          */
/* - http://www.sztaki.hu/~meszaros/public_ftp/qpdata/qpdata.ps */
/****************************************************************/


DEFUN_DLD(parse_qps, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[ @var{H}, @var{f}, @var{g}, @var{Aineq}, @var{bineq},\
 @var{Aeq}, @var{beq}, @var{lb}, @var{ub} ] =} parse_qps(@var{file}\n\
\n\
Parse a QPS file\n\
@end deftypefn") {
  // Output
  octave_value_list output;

  try {
    // Check the number of parameters
    if (args.length() != 1)
      throw (const char*)0;

    // Check first argument
    if (not args(0).is_string())
      throw "file should be a string";
    string file_name = args(0).string_value();

    // Open
    ifstream ifs(file_name.c_str());
    if (not ifs.is_open())
      throw "Cannot open file";

    /* NAME *********************************************************/

    // Get NAME line
    string line;
    if (not getline(ifs, line))
      throw "Cannot read NAME section";

    // Indeed NAME?
    if (line.substr(0, 4) != "NAME")
      throw "Did not find NAME section";
    // string name = trimmed_substr(line, 14, 22);

    /* ROWS *********************************************************/

    // Now should come ROWS
    if (not getline(ifs, line))
      throw "Cannot read ROWS section";

    // Indeed ROWS?
    if (line.substr(0, 4) != "ROWS")
      throw "Did not find ROWS section";

    // Row name mapping
    bool first_N = true;
    int n_eq     = 0;
    int n_ineq   = 0;
    map< string, pair<char, int> > row_map;
    
    // Loop until COLUMNS section
    if (not getline(ifs, line))
      throw "Cannot read ROWS contents";
    while (line.substr(0, 7) != "COLUMNS") {
      // Restriction char and name
      string row_restriction = trimmed_substr(line, 1,  3);
      string row_name        = trimmed_substr(line, 4, 12);

      // OK?
      if (row_restriction != "N" && row_restriction != "G" && 
	  row_restriction != "E" && row_restriction != "L")
	throw "Wrong ROWS entry restriction";
      if (row_name.empty())
	throw "Wrong ROWS entry name";

      // Already there?
      if (row_map.find(row_name) != row_map.end())
	throw "Repeated ROWS entry name";

      // Insert
      if (row_restriction[0] == 'N') {
	if (first_N) {
	  row_map.insert(make_pair(row_name, make_pair('N', 1)));
	  first_N = false;
	}
	else {
	  row_map.insert(make_pair(row_name, make_pair('N', 0)));
	}
      }
      else if (row_restriction[0] == 'E') {
	row_map.insert(make_pair(row_name, make_pair('E', n_eq++)));
      }
      else { // row_restriction[0] == 'L' || row_restriction[0] == 'G'
	row_map.insert(make_pair(row_name, make_pair(row_restriction[0], n_ineq++)));
      }

      // Next line
      if (not getline(ifs, line))
	throw "Cannot read ROWS contents";
    }

    /* COLUMNS ******************************************************/

    // Create Aeq and Aineq matrices
    Matrix       Aeq  (n_eq,   0);
    Matrix       Aineq(n_ineq, 0);
    ColumnVector f    (0);
    
    // Column names
    int n_vars = 0;
    map<string, int> col_map;

    // Loop until RHS section
    if (not getline(ifs, line))
      throw "Cannot read COLUMNS contents";
    while (line.substr(0, 3) != "RHS") {
      // Split
      string col_name   = trimmed_substr(line,  4, 12);
      string row1_name  = trimmed_substr(line, 14, 22);
      string row1_value = trimmed_substr(line, 24, 36);
      string row2_name  = trimmed_substr(line, 39, 47);
      string row2_value = trimmed_substr(line, 49, 61);

      // Check
      if (col_name.empty() or row1_name.empty() or row1_value.empty())
	throw "Wrong COLUMNS entry";

      // Index the name
      map<string, int>::iterator it = col_map.find(col_name);
      if (it == col_map.end()) {
	it = col_map.insert(make_pair(col_name, n_vars++)).first;
	Aeq  .RESIZE_AND_FILL(n_eq,   n_vars, 0.0);
	Aineq.RESIZE_AND_FILL(n_ineq, n_vars, 0.0);
	f    .RESIZE_AND_FILL(        n_vars, 0.0);
      }
      int col_idx = it->second;

      // First row
      map< string, pair<char, int> >::iterator rit = row_map.find(row1_name);
      if (rit == row_map.end())
	throw "Wrong row name in COLUMNS entry";

      // Convert the value
      double row_double = atof(row1_value.c_str());

      // Type
      switch (rit->second.first) {
      case 'N':
	if (rit->second.second == 1)
	  f(col_idx) = row_double;
	break;

      case 'E':
	Aeq(rit->second.second, col_idx) = row_double;
	break;

      case 'L':
	Aineq(rit->second.second, col_idx) = row_double;
	break;

      case 'G':
	Aineq(rit->second.second, col_idx) = -row_double;
	break;

      default:
	break;
      }
      
      // More values?
      if (not row2_name.empty()) {
	// Check
	if (row2_value.empty())
	  throw "Wrong COLUMNS entry";

	// Second row
	if ((rit = row_map.find(row2_name)) == row_map.end())
	  throw "Wrong row name in COLUMNS entry";

	// Convert the value
	row_double = atof(row2_value.c_str());

	// Type
	switch (rit->second.first) {
	case 'N':
	  if (rit->second.second == 1)
	    f(col_idx) = row_double;
	  break;

	case 'E':
	  Aeq(rit->second.second, col_idx) = row_double;
	  break;

	case 'L':
	  Aineq(rit->second.second, col_idx) = row_double;
	  break;

	case 'G':
	  Aineq(rit->second.second, col_idx) = -row_double;
	  break;

	default:
	  break;
	}
      }

      // Next line
      if (not getline(ifs, line))
	throw "Cannot read COLUMNS contents";
    }

    /* RHS **********************************************************/

    // Create beq and bineq vectors
    ColumnVector beq  (n_eq,   0.0);
    ColumnVector bineq(n_ineq, 0.0);
    double g = 0.0;

    // Loop until RANGES, BOUNDS, QUADOBJ or ENDATA section
    if (not getline(ifs, line))
      throw "Cannot read RHS contents";
    while (line.substr(0, 6) != "RANGES" and
	   line.substr(0, 6) != "BOUNDS" and
	   line.substr(0, 7) != "QUADOBJ" and
	   line.substr(0, 6) != "ENDATA") {
      // Split
      // string rhs_name   = trimmed_substr(line,  4, 12);
      string row1_name  = trimmed_substr(line, 14, 22);
      string row1_value = trimmed_substr(line, 24, 36);
      string row2_name  = trimmed_substr(line, 39, 47);
      string row2_value = trimmed_substr(line, 49, 61);

      // Ignore the name...

      // First row
      map< string, pair<char, int> >::iterator rit = row_map.find(row1_name);
      if (rit == row_map.end())
	throw "Wrong row name in RHS entry";

      // Convert the value
      double row_double = atof(row1_value.c_str());

      // Type
      switch (rit->second.first) {
      case 'N':
	if (rit->second.second == 1)
	  g = -row_double;
	break;

      case 'E':
	beq(rit->second.second) = row_double;
	break;

      case 'L':
	bineq(rit->second.second) = row_double;
	break;

      case 'G':
	bineq(rit->second.second) = -row_double;
	break;

      default:
	break;
      }
      
      // More values?
      if (not row2_name.empty()) {
	// Check
	if (row2_value.empty())
	  throw "Wrong RHS entry";

	// Second row
	if ((rit = row_map.find(row2_name)) == row_map.end())
	  throw "Wrong row name in RHS entry";

	// Convert the value
	row_double = atof(row2_value.c_str());

	// Type
	switch (rit->second.first) {
	case 'N':
	  if (rit->second.second == 1)
	    g = -row_double;
	  break;

	case 'E':
	  beq(rit->second.second) = row_double;
	  break;

	case 'L':
	  bineq(rit->second.second) = row_double;
	  break;

	case 'G':
	  bineq(rit->second.second) = -row_double;
	  break;

	default:
	  break;
	}
      }

      // Next line
      if (not getline(ifs, line))
	throw "Cannot read RHS contents";
    }
    
    /* RANGES *******************************************************/

    // Any RANGES?
    if (line.substr(0, 6) == "RANGES") {
      // Loop until BOUNDS, QUADOBJ or ENDATA section
      if (not getline(ifs, line))
	throw "Cannot read RANGES contents";
      while (line.substr(0, 6) != "BOUNDS" and
	     line.substr(0, 7) != "QUADOBJ" and
	     line.substr(0, 6) != "ENDATA") {
	// Split
	// string range_name = trimmed_substr(line,  4, 12);
	string row_name    = trimmed_substr(line, 14, 22);
	string range_value = trimmed_substr(line, 24, 36);
	
	// Ignore the name
	
	// Find row
	map< string, pair<char, int> >::iterator rit = row_map.find(row_name);
	if (rit == row_map.end())
	  throw "Wrong row name in RANGES entry";
	
	// Check it is not an E constraint
	if (rit->second.first == 'E')
	  throw "RANGES entries for E constraints is not supported";

	// Convert the value
	double range_double = abs(atof(range_value.c_str()));

	// Make a new inequality constraint
	++n_ineq;
	Aineq.RESIZE_AND_FILL(n_ineq, n_vars, 0.0);
	bineq.RESIZE_AND_FILL(n_ineq,         0.0);

	// Copy the inverted constraints
	for (int i = 0; i < n_vars; ++i)
	  Aineq(n_ineq - 1, i) = -Aineq(rit->second.second, i);

	// Update the range
	if (rit->second.first == 'L')
	  bineq(n_ineq - 1) = -(bineq(rit->second.second) - range_double);
	else
	  bineq(n_ineq - 1) = -bineq(rit->second.second) + range_double;
	
	// Next line
	if (not getline(ifs, line))
	  throw "Cannot read RANGES contents";
      }
    }

    /* BOUNDS *******************************************************/

    // Create lb and ub vectors
    ColumnVector lb(n_vars, 0.0);
    ColumnVector ub(n_vars, +INFINITY);

    // Any BOUNDS
    if (line.substr(0, 6) == "BOUNDS") {
      // Loop until QUADOBJ or ENDATA section
      if (not getline(ifs, line))
	throw "Cannot read BOUNDS contents";
      while (line.substr(0, 7) != "QUADOBJ" and
	     line.substr(0, 6) != "ENDATA") {
	// Split
	string bound_type  = trimmed_substr(line,  1, 3);
	// string bound_name  = trimmed_substr(line,  4, 12);
	string col_name    = trimmed_substr(line, 14, 22);
	string bound_value = trimmed_substr(line, 24, 36);

	// Ignore the name...

	// Check
	if (bound_type.empty() or col_name.empty())
	  throw "Wrong BOUNDS entry";

	// Index the column
	map<string, int>::iterator it = col_map.find(col_name);
	if (it == col_map.end()) {
	  it = col_map.insert(make_pair(col_name, n_vars++)).first;
	  Aeq  .RESIZE_AND_FILL(n_eq,   n_vars, 0.0);
	  Aineq.RESIZE_AND_FILL(n_ineq, n_vars, 0.0);
	  f    .RESIZE_AND_FILL(        n_vars, 0.0);
	  lb   .RESIZE_AND_FILL(        n_vars, 0.0);
	  ub   .RESIZE_AND_FILL(        n_vars, +INFINITY);
	}
	int col_idx = it->second;

	// Kind of bound
	if (bound_type == "LO" or bound_type == "UP" or bound_type == "FX") {
	  // Get the value
	  double bound_double = atof(bound_value.c_str());

	  // Set
	  if (bound_type == "LO") {
	    lb(col_idx) = bound_double;
	  }
	  else if (bound_type == "UP") {
	    ub(col_idx) = bound_double;
	  }
	  else { // bound_type == "FX"
	    lb(col_idx) = ub(col_idx) = bound_double;
	  }
	}
	else if (bound_type == "FR") {
	  // Set
	  lb(col_idx) = -INFINITY;
	  ub(col_idx) = +INFINITY;
	}
	else if (bound_type == "MI") {
	  // Set
	  lb(col_idx) = -INFINITY;
	}
	else if (bound_type == "PL") {
	  // Set
	  ub(col_idx) = +INFINITY;
	}
	else {
	  // Error
	  throw "Wrong bound type in BOUNDS entry";
	}

	// Next line
	if (not getline(ifs, line))
	  throw "Cannot read BOUNDS contents";
      }
    }

    /* QUADOBJ ******************************************************/

    // Quadratic objective matrix
    Matrix H(n_vars, n_vars, 0.0);

    // Any QUADOBJ
    if (line.substr(0, 7) == "QUADOBJ") {
      // Loop until ENDATA section
      if (not getline(ifs, line))
	throw "Cannot read QUADOBJ contents";
      while (line.substr(0, 6) != "ENDATA") {
	// Split
	string col1_name   = trimmed_substr(line,  4, 12);
	string col2_name   = trimmed_substr(line, 14, 22);
	string col12_value = trimmed_substr(line, 24, 36);
	string col3_name   = trimmed_substr(line, 39, 47);
	string col13_value = trimmed_substr(line, 49, 61);

	// Check
	if (col1_name.empty() or col2_name.empty() or col12_value.empty())
	  throw "Wrong BOUNDS entry";

	// Index column 1
	map<string, int>::iterator it1 = col_map.find(col1_name);
	if (it1 == col_map.end())
	  throw "Wrong column name in QUADOBJ section";

	// Index column 2
	map<string, int>::iterator it2 = col_map.find(col2_name);
	if (it2 == col_map.end())
	  throw "Wrong column name in QUADOBJ section";

	// Set
	double col_double = atof(col12_value.c_str());
	H(it1->second, it2->second) = H(it2->second, it1->second) = col_double;
	
	// More?
	if (not col3_name.empty()) {
	  // Check
	  if (col13_value.empty())
	    throw "Wrong BOUNDS entry";

	  // Index column 3
	  it2 = col_map.find(col3_name);
	  if (it2 == col_map.end())
	    throw "Wrong column name in QUADOBJ section";

	  // Set
	  col_double = atof(col13_value.c_str());
	  H(it1->second, it2->second) = H(it2->second, it1->second) = col_double;
	}

	// Next line
	if (not getline(ifs, line))
	  throw "Cannot read QUADOBJ contents";
      }
    }

    /* ENDATA *******************************************************/

    // Return
    output.resize(9);
    output(0) = H;
    output(1) = f;
    output(2) = g;
    output(3) = Aineq;
    output(4) = bineq;
    output(5) = Aeq;
    output(6) = beq;
    output(7) = lb;
    output(8) = ub;
  }
  // Was there an error?
  catch (const char* _error) {
    // Display the error or the usage
    if (_error)
      error(_error);
    else
      print_usage();
  }
  // Was there an exception
  catch (std::exception& _excep) {
    // Display the error
    error(_excep.what());
  }

  // Return the result
  return output;
}
