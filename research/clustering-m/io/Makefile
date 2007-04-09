all: 	cread_sparse.oct cread_sparse_idf.oct cread_labels.oct\
	read_labels_num.oct read_clustering.oct

cread_sparse.oct: cread_sparse.cc
	mkoctfile cread_sparse.cc

cread_sparse_idf.oct: cread_sparse.oct
	ln -sf cread_sparse.oct cread_sparse_idf.oct

cread_labels.oct: cread_sparse.oct
	ln -sf cread_sparse.oct cread_labels.oct

read_labels_num.oct: cread_sparse.oct
	ln -sf cread_sparse.oct read_labels_num.oct

read_clustering.oct: cread_sparse.oct
	ln -sf cread_sparse.oct read_clustering.oct
