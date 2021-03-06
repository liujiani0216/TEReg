#' @export
#' @import rTensor
#' @import MASS
#' @importFrom pracma kron sqrtm

TensEnv_dim <- function(Yn, Xn, multiD=1, bic_max=10, opts=NULL){
  ss <- dim(Yn)
  len <- length(ss)
  n <- ss[len]
  r <- ss[1:(len-1)]
  m <- length(r)
  prodr <- prod(r)
  p <- dim(Xn)[1]
  multiD <- p
  u <- r
  
  Xn_inv <- MASS::ginv(Xn %*% t(Xn)) %*% Xn
  Btil <- rTensor::ttm(Yn, Xn_inv, m+1)
  En <- Yn - rTensor::ttm(Btil, t(Xn), m+1)
  
  res <- kroncov(En)
  lambda <- res$lambda
  Sig <- res$S
  
  Sinvhalf <- NULL
  for (i in 1:m) {
    Sinvhalf[[i]] <- sqrtm(Sig[[i]])$Binv
  }
  
 
  for (i in 1:m) {
    M <- lambda*Sig[[i]]
    idx <-  c(1:(m+1))[c(1:(m+1))!=i]
    len <- length(idx)
    Ysn <- rTensor::ttl(Yn, Sinvhalf[c(idx[1:(len-1)])], ms=idx[1:(len-1)])
    idxprod <- (r[i]/n)/prodr
    YsnYsn <- ttt(Ysn, Ysn, dims=idx)@data*idxprod
    U <- YsnYsn - M
    res <- ballGBB1D_bic(M, U, n, multiD, bic_max, opts)
    u[i] <- res$u
  }
  return(u)
}