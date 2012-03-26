#include <algorithm>
#include <cassert>
#include <cmath>
#include <exception>
// #include <iostream>
#include <queue>
#include <vector>

#include <octave/oct.h>

// Queue element
struct queue_element {
  // Cost
  double cost;

  // Row
  octave_idx_type row;

  // Col
  octave_idx_type col;

  // Default constructor
  queue_element(double _cost = 0.0,
		octave_idx_type _row = 0,
		octave_idx_type _col = 0) :
    cost(_cost), row(_row), col(_col) {
  }

  // Comparison operator
  bool operator<(const queue_element& _other) const {
    if (cost != _other.cost)
      return cost < _other.cost;
    else if (row != _other.row)
      return row < _other.row;
    else
      return col < _other.col;
  }
};

// Group
struct group {
  // Sense
  enum { MULTI_ROW, ONE_ONE, MULTI_COL } sense;

  // Single
  /* In ONE_ONE, this is the row */
  octave_idx_type single;

  // Multi
  std::vector<octave_idx_type> multi;

  // Constructor from a row and col
  group(octave_idx_type _row, octave_idx_type _col) :
    sense(ONE_ONE), single(_row), multi(1, _col) {
  }
};

// Helper function
static void multi_assignment(const Matrix& _costs,
			     double& _cost,
			     ColumnVector& _row_map,
			     ColumnVector& _col_map,
			     int& _groups) {
  // Number of rows and columns
  octave_idx_type n_rows = _costs.rows();
  octave_idx_type n_cols = _costs.columns();

  // Create and fill the heap
  std::priority_queue<queue_element> heap;
  for (octave_idx_type r = 0; r < n_rows; ++r)
    for (octave_idx_type c = 0; c < n_cols; ++c)
      heap.push(queue_element(_costs(r, c), r, c));

  // Groups
  std::vector<group*> groups;

  // Group mapping
  std::vector<group*> row_group(n_rows, (group*)0);
  std::vector<group*> col_group(n_cols, (group*)0);

  // Cost so far
  _cost = 0.0;

  // While the heap is not empty
  while (not heap.empty()) {
    // Take the first
    double cost = heap.top().cost;
    octave_idx_type r = heap.top().row;
    octave_idx_type c = heap.top().col;

    // Row assignment?
    bool added = false;
    if (row_group[r]) {
      // Col assignment?
      if (col_group[c]) {
	// row_group[r] and col_group[c]

	// They can't be the same
	assert(row_group[r] != col_group[c]);
      }
      else {
	// row_group[r] and not col_group[c]
	switch (row_group[r]->sense) {
	case group::MULTI_ROW:
	  // Skip...
	  break;

	case group::ONE_ONE:
	  // Convert into a MULTI_COL
	  col_group[c] = row_group[r];
	  col_group[c]->sense = group::MULTI_COL;
	  col_group[c]->multi.push_back(c);
	  added = true;
	  break;

	case group::MULTI_COL:
	  // Just add
	  col_group[c] = row_group[r];
	  col_group[c]->multi.push_back(c);
	  added = true;
	  break;
	}
      }
    }
    else {
      // Col assignment?
      if (col_group[c]) {
	// not row_group[r] and col_group[c]
	switch (col_group[c]->sense) {
	case group::MULTI_ROW:
	  // Just add
	  row_group[r] = col_group[c];
	  row_group[r]->multi.push_back(r);
	  added = true;
	  break;

	case group::ONE_ONE:
	  // Convert into a MULTI_ROW
	  // (Switch first of multi and single!)
	  row_group[r] = col_group[c];
	  row_group[r]->sense = group::MULTI_ROW;
	  std::swap(row_group[r]->single, row_group[r]->multi.front());
	  row_group[r]->multi.push_back(r);
	  added = true;
	  break;

	case group::MULTI_COL:
	  // Skip...
	  break;
	}
      }
      else {
	// not row_group[r] and not col_group[c]

	// Add a new group
	groups.push_back(new group(r, c));
	row_group[r] = col_group[c] = groups.back();
	added = true;
      }
    }

    // Added?
    if (added) {
      // Debug
      // std::cerr << r << ' ' << c << ' ' << cost << std::endl;

      // Increase the cost
      _cost += cost;
    }

    // Pop
    heap.pop();
  }

  // Initialize mapping
#if OCTAVE_MAJOR > 3 || (OCTAVE_MAJOR == 3 && OCTAVE_MINOR >= 4)
  _row_map.resize(n_rows, -1);
  _col_map.resize(n_cols, -1);
#else
  _row_map.resize_fill(n_rows, -1);
  _col_map.resize_fill(n_cols, -1);
#endif

  // Groups
  for (unsigned int i = 0; i < groups.size(); ++i) {
    switch (groups[i]->sense) {
    case group::MULTI_ROW:
      // Assign column
      _col_map(groups[i]->single) = i + 1;

      // Assign each row
      for (std::vector<octave_idx_type>::const_iterator it =
	     groups[i]->multi.begin(); it != groups[i]->multi.end(); ++it)
	_row_map(*it) = i + 1;

      break;

    case group::ONE_ONE:
    case group::MULTI_COL:
      // Assign row
      _row_map(groups[i]->single) = i + 1;

      // Assign each column
      for (std::vector<octave_idx_type>::const_iterator it =
	     groups[i]->multi.begin(); it != groups[i]->multi.end(); ++it)
	_col_map(*it) = i + 1;

      break;
    }

    // Free the group
    delete groups[i];
  }

  // Groups
  _groups = groups.size();
}

// Octave callback
DEFUN_DLD(multi_assignment, args, nargout,
          "-*- texinfo -*-\n\
@deftypefn {Loadable Function}\
 {[ @var{cost}, @var{row_map}, @var{col_map}, @var{cost} ] =}\
 multi_assignment(@var{costs})\n\
\n\
Find the maximum multiple assignment with the given @var{cost} matrix\n\
@end deftypefn") {
  // Result
  octave_value_list result;

  try {
    // Check the number of parameters
    if (args.length() != 1 or nargout > 4)
      throw (const char*)0;

    // Check  cost
    if (not args(0).is_matrix_type())
      throw "costs should be a matrix";

    // Get cost
    Matrix costs = args(0).matrix_value();

    // Output
    double cost;
    ColumnVector row_map;
    ColumnVector col_map;
    int groups;

    // Call
    multi_assignment(costs, cost, row_map, col_map, groups);

    // Prepare output
    result.resize(4);
    result(0) = cost;
    result(1) = row_map;
    result(2) = col_map;
    result(3) = groups;
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
  return result;
}
