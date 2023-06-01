bifurcatr <- function(phy, runs = 1) 
{
  trees <- vector("list", length = runs)
  for (i in 1:runs) {
    tree <- phy
    resolves <- Ntip(tree) - Nnode(tree) - 1
    for (j in 1:resolves) {
      descendent_counts <- rle(sort(tree$edge[, 1]))
      polytomies <- descendent_counts$values[which(descendent_counts$lengths > 
                                                     2)]
      if (length(polytomies) > 1) 
        target_polytomy <- sample(polytomies, size = 1)
      else target_polytomy <- polytomies
      polytomy_edges <- which(tree$edge[, 1] == target_polytomy)
      target_edges <- sample(polytomy_edges, size = 2)
      new_node <- max(tree$edge) + 1
      tree$edge[target_edges, 1] <- new_node
      new_edge <- c(target_polytomy, new_node)
      tree$edge <- rbind(tree$edge, new_edge)
      new_length <- runif(n = 1, min = 0, max = min(tree$edge.length[target_edges]))
      tree$edge.length <- c(tree$edge.length, new_length)
      tree$edge.length[target_edges] <- tree$edge.length[target_edges] - 
        new_length
      tree$Nnode <- tree$Nnode + 1
    }
    trees[[i]] <- tree
  }
  if (runs == 1) {
    trees <- trees[[1]]
    class(trees) <- "phylo"
  }
  else {
    class(trees) <- "multiPhylo"
  }
  return(trees)
}
