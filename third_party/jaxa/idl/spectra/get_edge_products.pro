;+
; Name: get_edge_products
;
; Purpose:  Wrapper around EDGE_PRODUCTS procedure to turn it into a function
;
; Category:  GEN  SPECTRA
; Method:
; GET_EDGE_PRODUCTS has the same arguments as EDGE_PRODUCTS, except that it
; treats the choices of different output types as boolean keywords, and just returns
; the one selected.
; See EDGE_PRODUCTS documentation for meaning of keyword arguments.
;
; Example:  To return the [low,high] boundaries for contiguous channels in array:
;    result = get_edge_products(array, /edges_2)
;
; Written:  Kim Tolbert 26-Oct-2002
;-
;------------------------------------------------------------------------------

function get_edge_products, edges, mean=mean, gmean=gmean, width=width, $
	edges_2=edges_2, edges_1=edges_1, contiguous=contiguous, full=full

Edge_Products, edges, MEAN=this_mean, GMEAN=this_gmean, $
    WIDTH=this_width, EDGES_1=this_edges_1, EDGES_2=this_edges_2, $
    contiguous=contiguous

this_width = float( this_width )

CASE 1 OF
    Keyword_Set( EDGES_1 ): RETURN, this_edges_1
    Keyword_Set( FULL ): RETURN, {MEAN:this_mean, GMEAN:this_gmean, $
                                  WIDTH:this_width, $
                                  EDGES_1:this_edges_1, EDGES_2:this_edges_2}
    Keyword_Set( EDGES_2 ): RETURN, this_edges_2
    Keyword_Set( GMEAN ): RETURN, this_gmean
    Keyword_Set( WIDTH ): RETURN, this_width
    ELSE: RETURN, this_mean
endcase

end