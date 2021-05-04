## This script provides a simple example of building a heterogeneous contact
## matrix with two agent types (patients and healthcare workers)

## Updated Initial Parameters --------------------------------------------------

# Specify agent types
agent_types <- c("H","P")

# Specify size of agent types
n_types <- c(500,300)
n_agents <- sum(n_types)

# compute updated total agents
agents <- rep(agent_types,times = n_types)

agents


# contact matrix


## HCW -> HCW ------------------------------------------------------------------

cm1 <- matrix(rep(0.04,times = n_types[1]^2),nrow = n_types[1])

# row.names(cm1) <- rep(agents[1:5])
# colnames(cm1) <- rep(agents[1:5])

# generalization
row.names(cm1) <- rep(agents[1:n_types[1]])
colnames(cm1) <- rep(agents[1:n_types[1]])

cm1

## Patients -> Patients --------------------------------------------------------

cm2 <- matrix(rep(0.01,times = n_types[2]^2),nrow = n_types[2])

#row.names(cm2) <- rep(agents[6:8])
#colnames(cm2) <- rep(agents[6:8])

# generalization
row.names(cm2) <- rep(agents[n_types[1]+(1:n_types[2])])
colnames(cm2) <- rep(agents[n_types[1]+(1:n_types[2])])

cm2

## Patients -> HCWs (0.05) -----------------------------------------------------
cm3 <- matrix(rep(0.05,times = n_types[1]*n_types[2]),nrow = n_types[2])

#row.names(cm3) <- rep(agents[6:8])
#colnames(cm3) <- rep(agents[1:5])

# generalization
row.names(cm3) <- rep(agents[n_types[1]+(1:n_types[2])])
colnames(cm3) <- rep(agents[1:n_types[1]])

cm3

cbind(cm1,t(cm3))

cbind(cm3,cm2)

cm <- rbind(cbind(cm1,t(cm3)),
            cbind(cm3,cm2))

cm

# fix diagonal
diag(cm) <- 0

cm


cm[1:10,1:10]

cm[790:800,790:800]
