if __name__ == '__main__':
    with open("../R/problem_module.R") as filename:
        lines = filename.readlines()
        for line in lines:
            if "<- function(" in line:
                function_name = line.split("<-")[0]
                print(f"### {function_name.strip()}\n")
                print("#### Main Documentation\n")
                print("```{r, comment=NA, echo=FALSE}")
                print(f'tools::Rd2txt(paste0(root, "{function_name.strip()}", ext))\n```\n')

