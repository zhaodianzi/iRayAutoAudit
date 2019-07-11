function BW = myImRegionalMax(varargin)
int imregionalmax(Mat input, int nLocMax, float threshold, float minDistBtwLocMax, Mat locations)
{
    Mat scratch = input.clone();
    int nFoundLocMax = 0;
    for (int i = 0; i < nLocMax; i++) {
        Point location;
        double maxVal;
        minMaxLoc(scratch, NULL, &maxVal, NULL, &location);
        if (maxVal > threshold) {
            nFoundLocMax += 1;
            int row = location.y;
            int col = location.x;
            locations.at<int>(i,0) = row;
            locations.at<int>(i,1) = col;
            int r0 = (row-minDistBtwLocMax > -1 ? row-minDistBtwLocMax : 0);
            int r1 = (row+minDistBtwLocMax < scratch.rows ? row+minDistBtwLocMax : scratch.rows-1);
            int c0 = (col-minDistBtwLocMax > -1 ? col-minDistBtwLocMax : 0);
            int c1 = (col+minDistBtwLocMax < scratch.cols ? col+minDistBtwLocMax : scratch.cols-1);
            for (int r = r0; r <= r1; r++) {
                for (int c = c0; c <= c1; c++) {
                    if (vdist(Point2DMake(r, c),Point2DMake(row, col)) <= minDistBtwLocMax) {
                        scratch.at<float>(r,c) = 0.0;
                    }
                }
            }
        } else {
            break;
        }
    }
    return nFoundLocMax;
}